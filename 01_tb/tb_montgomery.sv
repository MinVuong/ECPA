`timescale 1ns / 1ps

module tb_montgomery;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg start;
    reg [255:0] A;
    reg [255:0] B;
    reg [255:0] P;
    wire [255:0] M;
    wire done;

    // Instantiate the Montgomery module
    montgomery uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .A(A),
        .B(B),
        .P(P),
        .M(M),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 1;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Test sequence
    initial begin
        // Initialize signals
        rst_n = 0;
        start = 0;
        A = 0;
        B = 0;
        P = 0;

        // Apply reset
        #10;
        rst_n = 1; // Release reset

        A = 256'd65; // 1
        B = 256'd565; // 2
        P = 256'd997; //  
        start = 1; 
        
    
        #6000; 
        start=0;
        $display("Test Case 1: A = %h, B = %h, P = %h , M = %h, Done = %b", A, B, P, M, done);

       rst_n=0;
        #100;
        rst_n = 1; // Release reset

        A = 256'd13; // 1
        B = 256'd37; // 2
        P = 256'd89; // 
        start = 1; 
        
    
        #6000; 
        start=0;
        $display("Test Case 1: A = %h, B = %h, P = %h , M = %h, Done = %b", A, B, P, M, done);


        $finish;
    end

endmodule