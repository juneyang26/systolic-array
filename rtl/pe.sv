module pe #(
    parameter int DATA_WIDTH = 8,
    parameter int ACCUM_WIDTH = 24
) (
    input logic clk, reset_n,
    input logic load_weights,
    //input logic load_accum,

    input logic signed [DATA_WIDTH-1:0] a_in,
    input logic signed [DATA_WIDTH-1:0] b_in,
    input logic signed [ACCUM_WIDTH-1:0] accumulator_in,

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
    end else if (load_weights) begin
        b <= b_in;
    end else begin
        a <= a_in;
        //current inputs so product isnt delayed by 1 cycle
        accum <= accumulator_in + a_in * b;
    end
end

assign accumulator_out = accum;
assign a_out = a;
assign b_out = b;
endmodule