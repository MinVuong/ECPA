`timescale 1ns/1ps

module tb_scalar_multiplication;
    reg clk, rst_n, start;
    reg [255:0] k, Px, Py, Pz, p;
    wire [255:0] R0_X, R0_Y, R0_Z;
    wire done;

    // Instantiate the DUT
    scalar_multiplication DUT (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_start(start),
        .k(k),
        .Px(Px), .Py(Py), .Pz(Pz),
        .p(p),
        .R0_X(R0_X), .R0_Y(R0_Y), .R0_Z(R0_Z),
        .o_done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        start = 0;
        k = 256'hB1A2B3C4D5E6F7080910111213141516;
        Px = 256'h3A4B5C6D7E8F908172636475869798A0;
        Py = 256'h112233445566778899AABBCCDDEEFF00;
        Pz = 256'h01010101010101010101010101010101;
        p  = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        
        #10 rst_n = 1; // Release reset
        #10 start = 1;
        #10 start = 0;
        
        // Wait for computation to complete
        wait(done);
        #20;
        
        // Display results
        $display("R0_X = %h", R0_X);
        $display("R0_Y = %h", R0_Y);
        $display("R0_Z = %h", R0_Z);
        
        $finish;
    end
endmodule
