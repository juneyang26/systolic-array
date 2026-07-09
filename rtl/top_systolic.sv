module top_systolic #(
    parameter int MEM_WORD_SIZE = 64,
    parameter int DATA_WIDTH = 8,
    parameter int ARRAY_SIZE = 2,
    parameter int ACCUM_WIDTH = 24
) (
    input logic clk,
    input logic reset_n,

    input logic [MEM_WORD_SIZE-1:0] r_data_temp, // temp until sram used
    output logic [ACCUM_WIDTH-1:0] w_data_temp [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0] // temp until sram used
);

    // Wires for controller
    logic                              load_weights;
    logic signed [MEM_WORD_SIZE-1:0]   r_data; // later will be from MEM, but for now just input
    logic signed [DATA_WIDTH-1:0]      weights_out [ARRAY_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]            A_out [ARRAY_SIZE-1:0];
    logic                              result_shift_en [ARRAY_SIZE-1:0];
    assign r_data = r_data_temp; // temp

    // Wires for systolic array
    logic signed [ACCUM_WIDTH-1:0] c_out [ARRAY_SIZE-1:0];
    logic signed [ACCUM_WIDTH-1:0] result_out [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];
    logic signed [ACCUM_WIDTH-1:0] result_write_out [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0]; // later will be to MEM, but for now just output
    // temporary below

    always_comb begin
        for (int i = 0; i < ARRAY_SIZE; i++) begin
            for (int j = 0; j < ARRAY_SIZE; j++) begin
                w_data_temp[i][j] = result_write_out[i][j];
            end
        end
    end

    // MEMORY (later)

    // CONTROLLER
    systolic_controller #(
        .MEM_WORD_SIZE(MEM_WORD_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ARRAY_SIZE(ARRAY_SIZE),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) u_systolic_controller (
        .clk(clk),
        .reset_n(reset_n),
        .r_data(r_data),
        // outputs to array
        .load_weights(load_weights),
        .weights_out(weights_out),
        .A_out(A_out),
        // in/output to result buffer
        .result_shift_en(result_shift_en),
        .result_in(result_out),

        //output later to SRAM
        .result_out(result_write_out)
    );

    // SYSTOLIC ARRAY
    systolic_array #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH),
        .ARRAY_SIZE(ARRAY_SIZE)
    ) u_systolic_array (
        .clk(clk),
        .reset_n(reset_n),
        .load_weights(load_weights),
        .a_in(A_out),
        .b_in(weights_out),
        // output to result buffer
        .c_out(c_out)
    );

    // Result Buffer
    result_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH),
        .ARRAY_SIZE(ARRAY_SIZE)
    ) u_result_buffer (
        .clk(clk),
        .reset_n(reset_n),
        .shift_en(result_shift_en),
        .accumulator_in(c_out),
        // output to SRAM (later)
        .result_out(result_out)
    );

endmodule
