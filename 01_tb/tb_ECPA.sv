`timescale 1ns / 1ps

module tb_ECPA;
    // Inputs
    reg         i_clk;
    reg         i_rst_n;
    reg         i_start;
    reg  [255:0] p;
    reg  [255:0] X1, Y1, Z1;
    reg  [255:0] X2, Y2, Z2;
    
    // Outputs
    wire [255:0] X3, Y3, Z3;
    wire         o_done;
    
    // Instantiate the Unit Under Test (UUT)
    ECPA uut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_start(i_start),
        .p(p),
        .X1(X1), .Y1(Y1), .Z1(Z1),
        .X2(X2), .Y2(Y2), .Z2(Z2),
        .X3(X3), .Y3(Y3), .Z3(Z3),
        .o_done(o_done)
    );
    
    // Clock generation
    always #5 i_clk = ~i_clk;
    
    initial begin
        // Initialize Inputs
        i_clk = 0;
        i_rst_n = 0;
        i_start = 0;
        p = 256'd23;
        X1 = 256'd5;
        Y1 = 256'd17;
        Z1 = 256'h1;
        X2 = 256'd7;
        Y2 = 256'd13;
        Z2 = 256'h1;
        
        // Reset sequence
        #10 i_rst_n = 1;
        #10 i_start = 1;
     
        
        // Wait for completion
        wait(o_done);
        #10 i_start =0;
        
        // Display results
        $display("X3 = %h", X3);
        $display("Y3 = %h", Y3);
        $display("Z3 = %h", Z3);
     

        p = 256'd233;
        X1 = 256'd51;
        Y1 = 256'd177;
        Z1 = 256'h1;
        X2 = 256'd79;
        Y2 = 256'd131;
        Z2 = 256'h1;
        
        // Reset sequence
       // #10 i_rst_n = 1;
        #10 i_start = 1;
     
        
        // Wait for completion
        wait(o_done);
        i_start =0;
        
        // Display results
        $display("X3 = %h", X3);
        $display("Y3 = %h", Y3);
        $display("Z3 = %h", Z3);
        // Finish simulation
        #20000;
        $finish;
    end
endmodule