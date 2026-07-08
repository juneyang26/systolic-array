module systolic_array #(
    parameter int DATA_WIDTH = 8,
    parameter int ACCUM_WIDTH = 24,
    parameter int ARRAY_SIZE = 2
) (
    input logic clk,
    input logic reset_n,
    input logic load_weights,

    // inputs a and b both have DATA_WIDTH amount of bits, and have ARRAY_SIZE elements.
    input logic signed [DATA_WIDTH-1:0] a_in [ARRAY_SIZE-1:0],
    input logic signed [DATA_WIDTH-1:0] b_in [ARRAY_SIZE-1:0],

    //output logic signed [ACCUM_WIDTH-1:0] c_out [ARRAY_SIZE][ARRAY_SIZE] // output matrix c = a x b has 4 elements
    output logic signed [ACCUM_WIDTH-1:0] c_out [ARRAY_SIZE-1:0]
);

    // BUS wire connecting input A to PE (down the row)
    logic signed [DATA_WIDTH-1:0] a_bus [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0]; // ex) a_in[0] -> PE00 -> PE01 

    // BUS wire input B to PE (down the col)
    logic signed [DATA_WIDTH-1:0] b_bus [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0]; // ex) b_in[0] -> PE00 -> PE10

    // accumulator BUS for the PEs
    logic signed [ACCUM_WIDTH-1:0] accum_bus [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];

    genvar row, col;
    generate
        for (row = 0; row < ARRAY_SIZE; row++) begin : gen_rows
            for (col = 0; col < ARRAY_SIZE; col++) begin : gen_cols 
                logic signed [DATA_WIDTH-1:0] a_in_wire;
                logic signed [DATA_WIDTH-1:0] b_in_wire;

                if (col == 0) begin
                    assign a_in_wire = a_in[row];
                end else begin
                    assign a_in_wire = a_bus[row][col-1];
                end

                if (row == 0) begin
                    assign b_in_wire = b_in[col];
                end else begin
                    assign b_in_wire = b_bus[row-1][col];
                end

                pe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ACCUM_WIDTH(ACCUM_WIDTH)
                )u_pe(
                    .clk(clk),
                    .reset_n(reset_n),
                    .load_weights(load_weights),
                    .a_in(a_in_wire),
                    .b_in(b_in_wire),
                    .accumulator_in(row == 0 ? '0 : accum_bus[row-1][col]),
                    .a_out(a_bus[row][col]), 
                    .b_out(b_bus[row][col]), 
                    .accumulator_out(accum_bus[row][col])
                );
            end
        end
    endgenerate

    //assign a_bus[0][0] = a_in;
    //assign b_bus[0][0] = b_in;

    //assign c_out = accum_bus;
    generate
        for (col = 0; col < ARRAY_SIZE; col++) begin : gen_c_out
            assign c_out[col] = accum_bus[ARRAY_SIZE-1][col];
        end
    endgenerate
endmodule