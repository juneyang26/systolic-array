// testing only the systolic array module for 2x2 example

module systolic_array_tb #(
    parameter int DATA_WIDTH = 8,
    parameter int ACCUM_WIDTH = 24,
    parameter int ARRAY_SIZE = 2
) ();

    localparam CLK_PERIOD = 20; // 20ns
    localparam DUTY_CYCLE = 0.5;


    logic clk_tb;
    logic reset_n_tb;
    logic load_weights_tb;

    
    initial begin
    forever
    begin
        #(CLK_PERIOD*DUTY_CYCLE) clk_tb = 1'b1;
        #(CLK_PERIOD*DUTY_CYCLE) clk_tb = 1'b0;
    end
    end

    logic signed [DATA_WIDTH-1:0] a_in_tb [ARRAY_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] b_in_tb [ARRAY_SIZE-1:0];
    logic signed [ACCUM_WIDTH-1:0] c_out_tb [ARRAY_SIZE-1:0];

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, systolic_array_tb);
        $dumpvars(0, u_systolic_array);
        $dumpvars(0, a_in_tb[0]);
        $dumpvars(0, a_in_tb[1]);
        $dumpvars(0, b_in_tb[0]);
        $dumpvars(0, b_in_tb[1]);
        $dumpvars(0, c_out_tb[0]);
        $dumpvars(0, c_out_tb[1]);
    end

    systolic_array_2x2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH),
        .ARRAY_SIZE(ARRAY_SIZE)
    ) u_systolic_array (
        .clk(clk_tb),
        .reset_n(reset_n_tb),
        .load_weights(load_weights_tb),
        .a_in(a_in_tb),
        .b_in(b_in_tb),
        .c_out(c_out_tb)
    );

    initial begin

        initialize_signals();

        // Apply test vectors
        // | 1 2 | x | 5 6 | = 
        // | 3 4 |   | 7 8 |

        // init weights first
        @(negedge clk_tb);
        load_weights_tb = 1'b1;
        b_in_tb[0] = 8'sd7;
        b_in_tb[1] = 8'sd8;
        @(posedge clk_tb);

        @(negedge clk_tb);
        b_in_tb[0] = 8'sd5;
        b_in_tb[1] = 8'sd6;
        @(posedge clk_tb);

        @(negedge clk_tb);
        load_weights_tb = 1'b0;
        // now weights are intialized/stationary

        // order of inputs are
        //      a10  a00 -> row0 of systolic array
        // a11  a01   X  -> row1 of systolic array
        @(negedge clk_tb);
        a_in_tb[0] = 8'sd1;
        a_in_tb[1] = '0;
        @(posedge clk_tb);

        @(negedge clk_tb);
        a_in_tb[0] = 8'sd3;
        a_in_tb[1] = 8'sd2;
        @(posedge clk_tb);

        @(negedge clk_tb);
        a_in_tb[0] = '0;
        a_in_tb[1] = 8'sd4;
        @(posedge clk_tb);

        #100;

        // Display the output matrix c_out
        //$display("Output matrix c_out:");
        //for (int i = 0; i < ARRAY_SIZE; i++) begin
        //    for (int j = 0; j < ARRAY_SIZE; j++) begin
        //        $write("%0d ", c_out[i][j]);
        //    end
        //    $write("\n");
        //end

        // Finish simulation
        $finish;
    end


    task initialize_signals();
    begin
        $display("------ Initializing signals -----\n");
        clk_tb = 1'b0;
        reset_n_tb = 1'b0;
        load_weights_tb = 1'b0;
        for (int i = 0; i < ARRAY_SIZE; i++) begin
            a_in_tb[i] = '0;
            b_in_tb[i] = '0;
            c_out_tb[i] = '0;
            //for (int j = 0; j < ARRAY_SIZE; j++) begin
            //    c_out_tb[i][j] = '0;
            //end
        end

        @(posedge clk_tb);
        @(posedge clk_tb);
        reset_n_tb = 1'b1;
    end
    endtask
endmodule