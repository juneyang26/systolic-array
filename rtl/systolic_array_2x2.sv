module systolic_array_2x2 #(
    parameter int DATA_WIDTH = 8,
    parameter int ACCUM_WIDTH = 24,
    parameter int ARRAY_SIZE = 2
) (
    input logic clk,
    input logic reset_n,
    
    // inputs a and b both have DATA_WIDTH amount of bits, and have ARRAY_SIZE elements.
    input logic signed [DATA_WIDTH-1:0] a_in [ARRAY_SIZE],
    input logic signed [DATA_WIDTH-1:0] b_in [ARRAY_SIZE],

    output logic signed [ACCUM_WIDTH-1:0] c_out [ARRAY_SIZE][ARRAY_SIZE] // output matrix c = a x b has 4 elements
);

    // BUS wire connecting input A to PE (down the row)
    logic signed [DATA_WIDTH-1:0] a_bus [ARRAY_SIZE][ARRAY_SIZE]; // ex) a_in[0] -> PE00 -> PE01 

    // BUS wire input B to PE (down the col)
    logic signed [DATA_WIDTH-1:0] b_bus [ARRAY_SIZE][ARRAY_SIZE]; // ex) b_in[0] -> PE00 -> PE10

    // accumulator BUS for the product
    logic signed [ACCUM_WIDTH-1:0] accum_bus [ARRAY_SIZE][ARRAY_SIZE];

    genvar row, col;
    generate
        for (row = 0; row < ARRAY_SIZE; row++) begin : gen_rows
            for (col = 0; col < ARRAY_SIZE; col++) begin : gen_cols 
                pe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ACCUM_WIDTH(ACCUM_WIDTH)
                )u_pe(
                    .clk(clk),
                    .reset_n(reset_n),
                    .a_in(col == 0 ? a_in[row] : a_bus[row][col-1]),
                    .b_in(row == 0 ? b_in[col] : b_bus[row-1][col]),
                    .a_out(a_bus[row][col]), 
                    .b_out(b_bus[row][col]), 
                    .accumulator_out(accum_bus[row][col])
                );
            end
        end
    endgenerate

    //assign a_bus[0][0] = a_in;
    //assign b_bus[0][0] = b_in;
    assign c_out = accum_bus;
endmodule