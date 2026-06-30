module systolic_controller (
    parameter int MEM_WORD_SIZE = 64,
    parameter int DATA_WIDTH = 8,
    parameter int ARRAY_SIZE = 2;
    parameter int ACCUM_WIDTH = 24,
) (
    input logic clk,
    input logic reset_n,

    // memory access (TODO LATER)

    input logic [MEM_WORD_SIZE-1:0] r_data;

    output logic load_weights,
);
    
    // states
    typedef enum logic [1:0] {
        S_IDLE,
        S_READ_WEIGHTS,
        S_LOAD_WEIGHTS,
        S_COMPUTE,
        S_GET_RESULTS
    } state_t;

    state_t state, next;
    
    // matrix registers
    logic [DATA_WIDTH-1:0]       matrix_A[ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];
    logic [DATA_WIDTH-1:0] matrix_weights[ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];

    always_comb begin 
        case (state)
            S_IDLE:  next = S_READ_WEIGHTS;
            S_READ_WEIGHTS: next = S_LOAD_WEIGHTS;
            S_LOAD_WEIGHTS: next = S_COMPUTE;
            S_COMPUTE: next = S_GET_RESULTS;
        
            default: next = S_IDLE;
        endcase
    end

    always_ff @(posedge clk) begin 
        if (!reset_n) begin
            state <= S_IDLE;
            matrix_A <= '0;
            matrix_weights <= '0;
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
                    genvar row, col;
                    generate
                        for (row = 0; row < ARRAY_SIZE; row++) begin
                            for (col = 0; col < ARRAY_SIZE; col++) begin
                                matrix_weights[row][col] <= r_data[]
                            end
                        end
                    endgenerate
                end
            endcase
        end
    end

endmodule