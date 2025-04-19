`timescale 1ns/1ps

module tb_ECC_top;

    // Inputs
    reg i_clk;
    reg i_rst_n;
    reg i_start;

    // Outputs
    wire done;

    // Instantiate the DUT (Device Under Test)
    ECC_top uut (
        .i_clk(i_clk),
        .i_start(i_start),
        .i_rst_n(i_rst_n),

        .done(done)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 10ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        i_start = 0;
        i_rst_n = 0;
   
        // Apply reset
        #20;
        i_rst_n = 1;
        i_start = 1; // Start the ECC operation

        // Test case 1: Basic ECC operation
        


        // Wait for the operation to complete
       wait(done);
       #50;
       wait(done);
       #50;
       wait(done);
       #50;
       wait(done);
       #50;
       wait(done);
       #50;
       wait(done);
       #50;
       wait(done);
       #50;
       wait(done);
       #50;
       wait(done);
       #50;
       wait(done);
       #50;
       wait(done);
       #50;
       wait(done);
       

      

       
        #50000;
        $finish;
    end

endmodule