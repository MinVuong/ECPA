`timescale 1ns/1ps

module tb_modular_addition;

    reg i_start;
    reg i_clk;
    reg i_rst_n;
    reg [255:0] A, B, p;
    wire [255:0] result;
    wire done;

    // Instantiate the DUT (Device Under Test)
    modular_addition uut (
        .i_start(i_start),
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .A(A),
        .B(B),
        .p(p),
        .result(result),
        .done(done)
    );

    // Clock generation
    always #5 i_clk = ~i_clk;

    initial begin
        // Initialize signals
        i_clk = 0;
        i_rst_n = 0;
        i_start = 0;
        A = 0;
        B = 0;
        p = 0;
        
        // Reset sequence
        #10 i_rst_n = 1;
        
        // Test case 1: A + B < p
        A = 256'h123456789;
        B = 256'h0;
        p = 256'hfffffffff;
        #10 i_start = 1;
        
        wait(done);
        $display("Test 1: result = %h", result);
        #500 i_start = 0;
          i_rst_n = 0;
         #10;
         i_rst_n =1;
        // Test case 2: A + B > p (should wrap around modulo p)
        A = 256'hff;
        B = 256'h20;
        p = 256'h100;
        #10 i_start = 1;
       
        wait(done);
        $display("Test 2: result = %h", result);
         #500 i_start = 0;
         i_rst_n = 0;
         #10;
         i_rst_n =1;
        // Test case 3: A + B = p (should result in 0)
        A = 256'hdeadbeef;
        B = 256'h2152412;
        p = 256'hffffffff;
        #10 i_start = 1;
        
        wait(done);
        $display("Test 3: result = %h", result);
        #500 i_start = 0;
          i_rst_n = 0;
         #10;
         i_rst_n =1;
        
        // End simulation
        #50;
        $finish;
    end
endmodule
