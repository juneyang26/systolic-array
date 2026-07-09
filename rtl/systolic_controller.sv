module systolic_controller #(
    parameter int MEM_WORD_SIZE = 64,
    parameter int DATA_WIDTH = 8,
    parameter int ARRAY_SIZE = 2,
    parameter int ACCUM_WIDTH = 24
) (
    input logic clk,
    input logic reset_n,

    // memory access (TODO LATER)

    input logic [MEM_WORD_SIZE-1:0] r_data,


    // systolic array
    output logic load_weights,
    output logic signed [DATA_WIDTH-1:0] weights_out [ARRAY_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0] A_out [ARRAY_SIZE-1:0],
    output logic result_shift_en [ARRAY_SIZE-1:0],

    // result buffer
    input logic signed [ACCUM_WIDTH-1:0] result_in [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0],

    output logic signed [ACCUM_WIDTH-1:0] result_out [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0] //temp
);
    
    // states
    typedef enum logic [2:0] {
        S_IDLE,
        S_READ_WEIGHTS,
        S_LOAD_WEIGHTS,
        S_READ_A,
        S_COMPUTE,
        S_GET_RESULTS,
        S_WRITE_RESULTS
    } state_t;

    //state_t state = S_IDLE, next = S_IDLE;
    state_t state, next;

    logic [DATA_WIDTH-1:0] counter;
    
    // matrix registers
    logic signed [DATA_WIDTH-1:0]       matrix_A[ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] matrix_weights[ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];

    always_comb begin 
        next = state; // default

        case (state)
            S_IDLE:         next = S_READ_WEIGHTS;
            S_READ_WEIGHTS: next = S_LOAD_WEIGHTS;
            S_LOAD_WEIGHTS: if (counter == ARRAY_SIZE - 1) next = S_READ_A;
            S_READ_A:       next = S_COMPUTE;
            S_COMPUTE:      if (counter == 2*ARRAY_SIZE - 2) next = S_GET_RESULTS;
            S_GET_RESULTS:  next = S_IDLE; // change logic once SRAM/addresses included
        
            default:        next = S_IDLE;
        endcase
    end

    always_ff @(posedge clk) begin 
        if (!reset_n) begin
            state <= S_IDLE;
            counter <= '0;
            for (int row = 0; row < ARRAY_SIZE; row++) begin
                for (int col = 0; col < ARRAY_SIZE; col++) begin
                    matrix_A[row][col] <= '0;
                    matrix_weights[row][col] <= '0;
                end
            end

            //matrix_A <= '0;
            //matrix_weights <= '0;
        end

        else begin 
            state <= next; // goto next state after
            case (state) 
                S_IDLE: begin
                    //if (ready)
                    // nothing for now
                end
                S_READ_WEIGHTS: begin
                    //matrix_weights[0][0] = r_data[7:0];

                    // read and store the weights in registers
                    for (int row = 0; row < ARRAY_SIZE; row++) begin
                        for (int col = 0; col < ARRAY_SIZE; col++) begin
                            // r_data will arrive packed like: MSB A[1][1], A[1][0], A[0][1], A[0][0] LSB for 2x2 array

                            // [<start_bit> +: <width>]  part-select increments from start-bit
                            // [<start_bit> -: <width>]  part-select decrements from start-bit
                            matrix_weights[row][col] <= r_data[(row * ARRAY_SIZE + col) * DATA_WIDTH +: DATA_WIDTH]; // read weights matrix
                        end
                    end

                end
                S_LOAD_WEIGHTS: begin 
                    //load_weights <= 1'b1;
                    // N rows, N cycles to load all weights
                    counter <= counter + 1;

                end
                S_READ_A: begin 
                    counter <= '0;

                    // read and store the matrix A in registers
                    for (int row = 0; row < ARRAY_SIZE; row++) begin
                        for (int col = 0; col < ARRAY_SIZE; col++) begin
                            // [<start_bit> +: <width>]  part-select increments from start-bit
                            // [<start_bit> -: <width>]  part-select decrements from start-bit
                            matrix_A[row][col] <= r_data[(row * ARRAY_SIZE + col) * DATA_WIDTH +: DATA_WIDTH]; // read matrix A
                        end
                    end

                end
                S_COMPUTE: begin
                    counter <= counter + 1;
                end
                S_GET_RESULTS: begin
                    //counter <= '0;
                end

            endcase
        end
    end

    

    // comb output logic
    always_comb begin
        // default values
        load_weights = '0;
        for (int b = 0; b < ARRAY_SIZE; b++) begin
            result_shift_en[b] = 0;
            weights_out[b] = '0;
            A_out[b] = '0;
        end

        case (state) 
            S_IDLE: begin
                
            end
            S_READ_WEIGHTS: begin 
                // need address later with SRAM
            end
            S_LOAD_WEIGHTS: begin 
                load_weights = 1'b1;
                for (int i = 0; i < ARRAY_SIZE; i++) begin
                    weights_out[i] = matrix_weights[counter][i];
                end
            end
            S_READ_A: begin
                // address later 
            end
            S_COMPUTE: begin
                for (int row = 0; row < ARRAY_SIZE; row++) begin
                    int row_stream = counter - row; // if counter = 2, then rows 0,1,2 should have elements streaming in, row 3 and onward should be bubble
                    
                    // 2 (counter) - 3 (curr row) = -1 -> do not stream in, bubble

                    // 0 (counter) - 0 (curr row) = 0  -> stream in 1st elememt of 1st col
                    // 1 (counter) - 0 (curr row) = 1  -> stream in 2nd element of 1st col
                    // 2 (counter) - 0 (curr row) = 2 >= ARRAY_SIZE -> out of elements to stream in
                    // 2 (counter) - 1 (next row) = 1  -> stream in 2nd element of 2nd col
                    
                    if (row_stream >= 0 && row_stream < ARRAY_SIZE) begin
                        A_out[row] = matrix_A[row_stream][row];
                    end else begin
                        A_out[row] = '0;
                    end

                    if (counter == 2*ARRAY_SIZE - 2) begin
                        result_shift_en[0] = 1'b1;
                    end
                end  
            end
            S_GET_RESULTS: begin
                // col i starts shifting at counter == i
                // colu ends shifting after counter == i + ARRAY_SIZE - 1
                for (int i = 0; i < ARRAY_SIZE; i++) begin
                    result_shift_en[i] = (counter >= i) && (counter < i+ARRAY_SIZE);
                end
            end
            S_WRITE_RESULTS: begin
                // write to SRAM later
                for (int i = 0; i < ARRAY_SIZE; i++) begin
                    for (int j = 0; j < ARRAY_SIZE; j++) begin
                        result_out[i][j] = result_in[i][j];
                    end
                end
                //result_out = result_in; // temp until sram added
            end
        endcase
    end

endmodule
