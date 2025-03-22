`timescale 1ns / 1ps

module tb_mont_final;

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
    mont_final uut (
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
        P = 256'd101; // Prime number for all test cases

        // Apply reset
        #10;
        rst_n = 1; // Release reset

        // Test Case 1
        
        A = 256'd3;  B = 256'd5;
        start = 1;
        wait(done);
        
        $display("Test Case 1: A = %h, B = %h, P = %h , M = %h", A, B, P, M);
        start = 0;

        // Test Case 2
        #10;
    
        A = 256'd7;  B = 256'd11;
        start = 1;
        wait(done);
        start = 0;
        $display("Test Case 2: A = %h, B = %h, P = %h , M = %h", A, B, P, M);

        // Test Case 3
        #100;
    
        A = 256'd13; B = 256'd17;
        start = 1;
        wait(done);
        start = 0;
        $display("Test Case 3: A = %h, B = %h, P = %h , M = %h", A, B, P, M);

        // Test Case 4
        #100;
      
        A = 256'd19; B = 256'd23;
        start = 1;
        wait(done);
        start = 0;
        $display("Test Case 4: A = %h, B = %h, P = %h , M = %h", A, B, P, M);

        // Test Case 5
        #100;
    
        A = 256'd29; B = 256'd31;
        start = 1;
        wait(done);
        start = 0;
        $display("Test Case 5: A = %h, B = %h, P = %h , M = %h", A, B, P, M);

        $finish;
    end

endmodule
