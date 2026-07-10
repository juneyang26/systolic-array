// testbench for systolic array top module without SRAM
`timescale 1ns/1ps

module top_systolic_tb #(
    parameter int MEM_WORD_SIZE = 64,
    parameter int DATA_WIDTH = 8,
    parameter int ARRAY_SIZE = 2,
    parameter int ACCUM_WIDTH = 24
) ();

    localparam CLK_PERIOD = 20; // 20ns
    localparam DUTY_CYCLE = 0.5;

    logic clk_tb;
    logic reset_n_tb;
    logic [MEM_WORD_SIZE-1:0] r_data_temp_tb;
    logic [ACCUM_WIDTH-1:0] w_data_temp_tb [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];

    // logic signed [DATA_WIDTH-1:0] a_in_0_dbg;
    // logic signed [DATA_WIDTH-1:0] a_in_1_dbg;
    // logic signed [DATA_WIDTH-1:0] b_in_0_dbg;
    // logic signed [DATA_WIDTH-1:0] b_in_1_dbg;

    initial begin
        forever
        begin
            #(CLK_PERIOD*DUTY_CYCLE) clk_tb = 1'b1;
            #(CLK_PERIOD*DUTY_CYCLE) clk_tb = 1'b0;
        end
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, top_systolic_tb);

    end

    top_systolic #(
        .MEM_WORD_SIZE(MEM_WORD_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ARRAY_SIZE(ARRAY_SIZE),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) u_top_systolic (
        .clk(clk_tb),
        .reset_n(reset_n_tb),
        .r_data_temp(r_data_temp_tb),
        .w_data_temp(w_data_temp_tb)
    );


    initial begin
        initialize_signals();
        @(negedge clk_tb); // idle

        // | 1 2 | x | 5 6 | = | 19 22 |
        // | 3 4 |   | 7 8 |   | 43 50 |
        r_data_temp_tb = 64'h0000000008070605; // send in weights

        @(posedge clk_tb); // read weights
        repeat(ARRAY_SIZE) @(posedge clk_tb); // load weights

        r_data_temp_tb = 64'h0000000004030201; // send in A
        @(posedge clk_tb); // read A
        //repeat(2*ARRAY_SIZE - 1) @(posedge clk_tb); // compute

        repeat(10) begin
            @(posedge clk_tb);
            $display("w_data_temp_tb[0][0] = %d, w_data_temp_tb[0][1] = %d, w_data_temp_tb[1][0] = %d, w_data_temp_tb[1][1] = %d", 
                w_data_temp_tb[0][0], w_data_temp_tb[0][1], w_data_temp_tb[1][0], w_data_temp_tb[1][1]);
        end
        $finish;

    end


    task initialize_signals();
    begin
        $display("------ Initializing signals -----\n");
        clk_tb = 1'b0;
        reset_n_tb = 1'b0;
        r_data_temp_tb = '0;
        for (int i = 0; i < ARRAY_SIZE; i++) begin
            for (int j = 0; j < ARRAY_SIZE; j++) begin
                w_data_temp_tb[i][j] = '0; // make matrix 0
            end
        end

        @(posedge clk_tb);
        @(posedge clk_tb);
        reset_n_tb = 1'b1;
        $display("------ Finished initializing signals -----\n");
    end
    endtask
endmodule
