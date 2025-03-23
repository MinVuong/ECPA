`timescale 1ns/1ps

module tb_modular_multiplication;
    reg clk, rst_n, start;
    reg [255:0] a, b, m;
    wire [255:0] p;
    wire ready;
 

    // Instantiate the DUT (Device Under Test)
    modular_multiplication uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .a(a),
        .b(b),
        .m(m),
        .p(p),
        .ready(ready)
       // .busy(busy),
        //.ready0(ready0)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        start = 0;
        a = 256'h0;
        b = 256'h0;
        m = 256'h0;

        // Reset sequence
        #10 rst_n = 1;
        #10;

        // Test Case 1: a = 3, b = 4, m = 5 -> Expected p = (3*4) mod 5 = 2
        a = 256'h1;
        b = 256'h1;
        m = 256'd23;
        start = 1;
        
        
        // Wait for computation to complete
        wait (ready);
        #10 start = 0;
        $display("Test Case 1: p = %h", p);
        #10;
         b = 256'hF7E75FDC469067FFDC439B16B7D2F0FBA2F3B5A6ABF5A7E7CE0F05EDDA3C339B;
        a = 256'hE5A3B45D7F29DCE6E89E3F08A7F68DAE8B771B75D7422F9A63FA9D423D51D6E9;
        m = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF43;
        start = 1;
       
        wait (ready);
         #10 start = 0;
        $display("Test Case 1: p = %h", p);
        

        #100;
        $finish;
    end
endmodule
