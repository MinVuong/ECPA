module tb_scalar_mult;
    reg clk, rst_n, start;
    reg [255:0] k, X, Y, Z, p;
    wire [255:0] X_out, Y_out, Z_out;
    wire o_done;
    
    ScalarMult uut (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_start(start),
        .k(k),
        .X(X), .Y(Y), .Z(Z),
        .p(p),
        .X_out(X_out), .Y_out(Y_out), .Z_out(Z_out),
        .o_done(o_done)
    );
    
    always #5 clk = ~clk; // 10ns clock period
    initial begin
        $monitor("Time: %0t | X0: %h, Y0: %h, Z0: %h | X1: %h, Y1: %h, Z1: %h | o_done: %b",
                 $time, uut.X0, uut.Y0, uut.Z0, uut.X1, uut.Y1, uut.Z1, o_done);
    end
    initial begin
        clk = 0; 
        rst_n = 0;
        start = 0;
        k = 256'hd83715f87b79685cdc41927073554fa5d6ddc3d8e9327ee7ac9fc6a0eed765ed;
        X = 256'h4b82bf5f6655ac6be5f66fc070f0f31838cb375027040d0ab1b5680c84f43127;
        Y = 256'h01c08b7d0e94c0dcb7defda9224f53e61e47fe20ad2420a71de13d393f2b9399;
        Z = 256'h1;
        p = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
        
        #20 rst_n = 1;
        #20 start = 1;

        
        wait(o_done);
        $display("Scalar Multiplication Complete:");
        $display("X_out = %h", X_out);
        $display("Y_out = %h", Y_out);
        $display("Z_out = %h", Z_out);
       // $monitor("Time: %0t | X0: %h, Y0: %h, Z0: %h | X1: %h, Y1: %h, Z1: %h", $time, X0, Y0, Z0, X1, Y1, Z1);
       
        $finish;
    end
endmodule
