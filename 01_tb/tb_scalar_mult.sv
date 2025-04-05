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
    reg [7:0] bit_pos; // Assuming bit_pos is 8 bits, adjust size if needed

    // Monitor bit_pos changes and display X0, Y0, Z0, X1, Y1, Z1
    always @(uut.bit_pos) begin
        $display("Time: %0t | bit_pos: %0d | X0: %h, Y0: %h, Z0: %h | X1: %h, Y1: %h, Z1: %h",
                 $time, uut.bit_pos, uut.X0, uut.Y0, uut.Z0, uut.X1, uut.Y1, uut.Z1);
    end

    initial begin
        clk = 0; 
        rst_n = 0;
        start = 0;
     k = 256'h43F86641A085AF50C1293D806FBFC66FF4FA3EFC54F91FEBB8A87F6A379DF8CF;
X = 256'h981862A18D2F3391A5BD8ACB7DB6CE5EEEDBC2E38DF59600C6EC94DBB4A2D55B;
Y = 256'hA82576ADB5EA5015343D863C9AA585FF8AD2B4FDF9D7A703F0CB6F69C92513C3;
Z = 256'h0000000000000000000000000000000000000000000000000000000000000001;
p = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;

        
        #20 rst_n = 1;
        #20 start = 1;

        
        wait(o_done);
        $display("Scalar Multiplication Complete:");
        $display("X_out = %h", X_out);
        $display("Y_out = %h", Y_out);
        $display("Z_out = %h", Z_out);
       // $monitor("Time: %0t | X0: %h, Y0: %h, Z0: %h | X1: %h, Y1: %h, Z1: %h", $time, X0, Y0, Z0, X1, Y1, Z1);
       #2000;
        $finish;
    end
endmodule
