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
        X1 = 256'hc8f2ba878ab210d813192ed555dd98e795f7aeec88aed4b3bfaed657f1b7eb3a;
Y1 = 256'h0bda444a45c50f30364236260fc039f3371fa32573b3dde5df7805e64ad42f67;
Z1 = 256'hade28d806d34062751720cba9432ff6880e2fa15a43b74469f73cf2cfdd251cb;
        X2 = 256'h16320747bad974ca019c47dd88f67a16e00ad24e4f584f9fb448edc6e74edb48;
Y2 = 256'h8585aad388a9f56fff2384f8effed6cb4ff74828392830e78d3478f6a5f30773;
Z2 = 256'h14e0c30ec0925b1b45b60f4f50318a50f076ba6bec0dee4e52a5fb111572d64b;


        
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