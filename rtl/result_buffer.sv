module result_buffer #(
    parameter int DATA_WIDTH = 8,
    parameter int ACCUM_WIDTH = 24,
    parameter int ARRAY_SIZE = 2
) (
    input logic clk,
    input logic reset_n,
    input logic shift_en [ARRAY_SIZE-1:0], // shift enable signal for each col
    input logic signed [ACCUM_WIDTH-1:0] accumulator_in [ARRAY_SIZE-1:0],

    output logic signed [ACCUM_WIDTH-1:0] result_out [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0] // resultant matrix;

);

    logic signed [ACCUM_WIDTH-1:0] result [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];

    // each column of the systolic array goes into a shift register

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            for (int row = 0; row < ARRAY_SIZE; row++) begin
                for (int col = 0; col < ARRAY_SIZE; col++) begin
                    result[row][col] <= '0; // reset all registers to 0
                end
            end
        end else begin
            for (int col = 0; col < ARRAY_SIZE; col++) begin
                if (shift_en[col]) begin
                    // each column shifts downward in the RF
                    for (int row_shift = 0; row_shift < ARRAY_SIZE - 1; row_shift++) begin
                        result[row_shift][col] <= result[row_shift+1][col];
                    end
                    
                    // top register result[N-1][0] fed from systolic array
                    result[ARRAY_SIZE-1][col] <= accumulator_in[col];
                end
            end
        end
    end


    assign result_out = result;
endmodule