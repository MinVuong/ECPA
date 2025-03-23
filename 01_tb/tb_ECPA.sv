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
          p =  256'hD4E6F8A1B3C5D7E9F2A4C6D8E1B3F5A7C9D2E4F6A8B1C3D5E7F9A2B4C6D8E1F3;
        X1 = 256'h827F8DA5B3C4E6F1D2A7C9E8B6D4F3A1C5E2F7D9B8A6C3E5F2D7B9A4C1E6F3D8;
        Y1 = 256'h91A3B5C7D9E2F4A6C8D1E3F5B7A9C2D4E6F8B1A3D5C7E9F2B4A6D8C1E3F5B7A9;
        Z1 = 256'h1;
        X2 = 256'hA2B3C4D5E6F708192A3B4C5D6E7F8091A2B3C4D5E6F708192A3B4C5D6E7F8091;
        Y2 = 256'hB6D8E1F3A5C7D9E2F4A6B8C1D3E5F7A9B2C4D6E8F1A3B5C7D9E2F4A6B8C1D3E5;
        Z2 = 256'h1;
        
        // Reset sequence
        #10 i_rst_n = 1;
        #10 i_start = 1;
     
        
        // Wait for completion
        wait(o_done);
        #10 i_start =0;
        #10 i_rst_n = 0;
        
        // Display results
        $display("X3 = %h", X3);
        $display("Y3 = %h", Y3);
        $display("Z3 = %h", Z3);

        p = 256'd23;
        X1 = 256'd5;
        Y1 = 256'd17;
        Z1 = 256'h1;
        X2 = 256'd7;
        Y2 = 256'd13;
        Z2 = 256'h1;
        // Reset sequence
       // #10 i_rst_n = 1;
        #10 i_rst_n = 1;
        #10
        i_start = 1;
     
        
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