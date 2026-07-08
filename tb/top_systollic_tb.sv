module top_systolic #(
    parameter int MEM_WORD_SIZE = 64,
    parameter int DATA_WIDTH = 8,
    parameter int ARRAY_SIZE = 2,
    parameter int ACCUM_WIDTH = 24
) (
    input logic clk,
    input logic reset_n,

    input [MEM_WORD_SIZE-1:0] r_data_temp; // temp until sram used
);

    // wires for controller
    logic                       load_weights;
    logic [MEM_WORD_SIZE-1:0]   r_data; // later will be from MEM, but for now just input
    logic [DATA_WIDTH-1:0]      weights_out [ARRAY_SIZE-1:0];
    logic [DATA_WIDTH-1:0]            A_out [ARRAY_SIZE-1:0];
    logic                   result_shift_en [ARRAY_SIZE-1:0];
    assign r_data = r_data_temp; // temp

    // wire for systolic array
    logic signed [ACCUM_WIDTH-1:0] c_out [ARRAY_SIZE-1:0];

endmodule