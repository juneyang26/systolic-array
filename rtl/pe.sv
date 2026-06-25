module pe #(
    parameter int DATA_WIDTH = 8,
    parameter int ACCUM_WIDTH = 24
) (
    input logic clk, reset_n,
    input logic signed [DATA_WIDTH-1:0] a_in,
    input logic signed [DATA_WIDTH-1:0] b_in,

    output logic signed [DATA_WIDTH-1:0] a_out,
    output logic signed [DATA_WIDTH-1:0] b_out,
    output logic signed [ACCUM_WIDTH-1:0] accumulator_out
);

logic signed [DATA_WIDTH-1:0] a, b;
logic signed [ACCUM_WIDTH-1:0] accum;

always_ff @(posedge clk) begin
    if (!reset_n) begin
        a <= '0;
        b <= '0;
        accum <= '0;
    end else begin
        a <= a_in;
        b <= b_in;
        //current inputs so product isnt delayed by 1 cycle
        accum <= accum + a_in * b_in;
    end
end

assign accumulator_out = accum;
assign a_out = a;
assign b_out = b;
endmodule