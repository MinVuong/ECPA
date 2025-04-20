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
    // Doan code nay de kiem tra cac signal trong module ECC_top, hienj memory trong module regfile
    /*
    integer i;
    always @(uut.regfile_inst.memory) begin
        $display("Time: %0t | Memory Contents Changed:", $time);
        for (i = 0; i < 32; i = i + 1) begin // Assuming memory has 32 entries
            $display("memory[%0d] = %h", i, uut.regfile_inst.memory[i]);
        end
    end
    */

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
       #50;
       wait(done);
         #50;
        wait(done);
        #50;
       
        $finish;
    end

endmodule