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

    integer cycle_count = 0;

    initial begin
        forever
        begin
            #(CLK_PERIOD*DUTY_CYCLE) clk_tb = 1'b1;
            #(CLK_PERIOD*DUTY_CYCLE) clk_tb = 1'b0;
        end
    end

    always_ff @(posedge clk_tb) begin
        if (!reset_n_tb) begin
            cycle_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
        end
    end

    initial begin
        // OpenSource: Use Verilator + GTKWave. (Icarus Verilog does not track unpacked arrays well)
        // Cadence: Xcelium + SimVision
        `ifdef CADENCE
        $shm_open("waves.shm");
        $shm_probe("ACM");
        `else
        $dumpfile("wave.vcd");
        $dumpvars(0, top_systolic_tb);
        `endif

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


    // test vectors
    integer fa, fb, fc;
    integer status;
    integer errors, test_num = 0;

    logic signed [DATA_WIDTH-1:0] A_matrix [ARRAY_SIZE][ARRAY_SIZE];
    logic signed [DATA_WIDTH-1:0] B_matrix [ARRAY_SIZE][ARRAY_SIZE];
    logic signed [ACCUM_WIDTH-1:0] C_expected [ARRAY_SIZE][ARRAY_SIZE];

    initial begin
        initialize_signals();
        //@(negedge clk_tb); // idle

        fa = $fopen("../scripts/A_vectors.txt","r");
        fb = $fopen("../scripts/B_vectors.txt","r");
        fc = $fopen("../scripts/C_vectors.txt","r");

        if (fa == 0 || fb == 0 || fc == 0) begin
            $fatal("Couldn't open vector files. fa=%0d, fb=%0d, fc=%0d", fa, fb, fc);
        end

        while (!$feof(fa)) begin
            // grab the matrices from the generated tests
            test_num++;
            errors = 0;
            @(negedge clk_tb); // middle of read_weights cycle

            status = $fscanf(fa,"%d %d %d %d",
                A_matrix[0][0], A_matrix[0][1],
                A_matrix[1][0], A_matrix[1][1]);

            status = $fscanf(fb,"%d %d %d %d",
                B_matrix[0][0], B_matrix[0][1],
                B_matrix[1][0], B_matrix[1][1]);

            status = $fscanf(fc,"%d %d %d %d",
                C_expected[0][0], C_expected[0][1],
                C_expected[1][0], C_expected[1][1]);

            if (status != ARRAY_SIZE*ARRAY_SIZE) begin
                break;
            end

            // load weights matrix into r_data to send to controller
            // r_data_temp_tb = '0
            for (int row = 0; row < ARRAY_SIZE; row++) begin
                for (int col = 0; col < ARRAY_SIZE; col++) begin
                    r_data_temp_tb[(row*ARRAY_SIZE + col)*DATA_WIDTH +: DATA_WIDTH] = B_matrix[row][col];
                end
            end

            @(posedge clk_tb); // read weights
            repeat(ARRAY_SIZE) @(posedge clk_tb); // load weights
            
            // load A matrix into r_data to send to controller
            for (int row = 0; row < ARRAY_SIZE; row++) begin
                for (int col = 0; col < ARRAY_SIZE; col++) begin
                    r_data_temp_tb[(row*ARRAY_SIZE + col)*DATA_WIDTH +: DATA_WIDTH] = A_matrix[row][col];
                end
            end

            @(posedge clk_tb); // read A
            repeat(2*ARRAY_SIZE - 1) @(posedge clk_tb); // compute
            repeat(2*ARRAY_SIZE - 2) @(posedge clk_tb); // shift out results

            @(negedge clk_tb); // middle of write_results cycle
            $display("Checking result for test %0d at cycle %0d", test_num, cycle_count);
            // compare result with expected
            for (int row = 0; row < ARRAY_SIZE; row++) begin
                for (int col = 0; col < ARRAY_SIZE; col++) begin
                    if (w_data_temp_tb[row][col] !== C_expected[row][col]) begin
                        $display("Error: w_data_temp_tb[%0d][%0d] = %0d, expected %0d", 
                            row, col, w_data_temp_tb[row][col], C_expected[row][col]);
                        errors++;
                    end
                end
            end

            if (errors == 0) begin
                $display("Test passed!");
            end else begin
                $display("Test %0d: failed with %0d errors.", test_num, errors);
            end
            
            @(posedge clk_tb); // goto idle
            @(posedge clk_tb); // enter read weights state
        end


        /*
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

        */


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
        @(negedge clk_tb);
        reset_n_tb = 1'b1;
        $display("------ Finished initializing signals -----\n");
    end
    endtask
endmodule
