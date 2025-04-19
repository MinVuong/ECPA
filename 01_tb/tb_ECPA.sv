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
          p =  256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
        X1 = 256'he9cb21aec1679b6f6f2a847bf473d65d26e904335c18e4bfefd52ed5aeec36ff;
        Y1 = 256'h2b0d925eb5c54dc5cc76c0729079551031a686fcc7c350659de3dad85e56b8d0;
        Z1 = 256'h433d230bf66fdb0046115aae771ce032b037a823612cec636107814d83907982;
        X2 = 256'hb86fd6b80ab0685a810a932298e80ab9e3c65c715b9c121af9f5730639d76fdc;
        Y2 = 256'h4b8c3c9f5e50232496caa9f3aa682b9091a5755977e0717e38bcd91c59d041b2;
        Z2 = 256'hf7d03c2832df6c93871fc86c2e27ab6c02ebdee34c7529cca318dea124ca6b0b;


        
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
       // Z1 = 256'h1;
        X2 = 256'd7;
        Y2 = 256'd13;
       // Z2 = 256'h1;
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