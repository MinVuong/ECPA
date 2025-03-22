`timescale 1ns / 1ps

module tb_BK256;

    reg clk;
    reg rst_n;
    reg start;
    reg [255:0] A;
    reg [255:0] B;
    reg Ci;
    wire [255:0] S;
    wire done;
    wire Co;

    // Instantiate the DUT (Device Under Test)
    BK256 dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .A(A),
        .B(B),
        .Ci(Ci),
        .S(S),
        .done(done),
        .Co(Co)
    );

    // Clock generation (10ns period -> 100MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 1;
        rst_n = 0;
        start = 0;
        A = 0;
        B = 0;
        Ci = 0;

        // Reset the system
        #10;
        rst_n = 1;
        #10;

        // First test case
        start = 1;
        A = 256'h1;
        B = 256'h4;
        Ci = 0;
        
        #200; // Wait for some clock cycles

        start = 0;

        #100; // Wait and check the output
        if (S == (A + B)) 
            $display("Test 1 Passed: A + B = S");
        else 
            $display("Test 1 Failed: Expected %h, Got %h", A+B, S);

        // Second test case
        #50;
        start = 1;
        A = 256'hA;
        B = 256'h5;
        Ci = 0;

        #200; // Wait for some clock cycles

        start = 0;

        #100; // Wait and check the output
        if (S == (A + B)) 
            $display("Test 2 Passed: A + B = S");
        else 
            $display("Test 2 Failed: Expected %h, Got %h", A+B, S);

        // Third test case: Adding 1 to max value
        #50;
        start = 1;
        A = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        B = 256'h0000000000000000000000000000000000000000000000000000000000000001;
        Ci = 0;

        #200; // Wait for some clock cycles

        start = 0;

        #100; // Wait and check the output
        if (S == (A + B)) 
            $display("Test 3 Passed: A + B = S");
        else 
            $display("Test 3 Failed: Expected %h, Got %h", A+B, S);

        // Finish simulation
        #50;
        $finish;
    end

endmodule
