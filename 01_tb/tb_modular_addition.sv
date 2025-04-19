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
        A = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc4b;
        B = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffd1d;
        p = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffe19;
        #10 i_start = 1;
        
        wait(done);
        $display("Test 1: result = %h", result);
        i_start = 0;
        #10 i_rst_n = 0; // Deactivate reset signal
        #10;
        //Test case 2: A + B > p
        i_rst_n = 1; // Activate reset signal   
        i_start = 1; // Deactivate start signal
  
        A = 256'hff;
        B = 256'h20;
        p = 256'h100;
    
       
        wait(done);
        $display("Test 2: result = %h", result);
        i_start = 0;
        #10 i_rst_n = 0; // Deactivate reset signal
    
        #500000;
        $finish;
    end
endmodule
