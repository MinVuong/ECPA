module tb_scalar_mult;

    reg clk, rst_n, start;
    reg [255:0] k, X, Y, Z, p;
    wire [255:0] X_out, Y_out, Z_out;
    wire o_done;

    // Kết nối module ECPM
    ECPM uut (
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

    integer file; // File descriptor for output file

    // Hiển thị và ghi kết quả ngay sau khi R0, R1 được cập nhật
    always @(posedge clk) begin
        if (uut.state == uut.COMPUTE) begin
            $display("Time: %0t | State: COMPUTE | bit_pos: %0d | k[bit_pos] = %b", $time, uut.bit_pos, k[uut.bit_pos]);
            $display("  Updated R0: X0 = %h, Y0 = %h, Z0 = %h", uut.X0, uut.Y0, uut.Z0);
            $display("  Updated R1: X1 = %h, Y1 = %h, Z1 = %h", uut.X1, uut.Y1, uut.Z1);

            // Ghi kết quả vào tệp
            $fwrite(file, "Time: %0t | State: COMPUTE | bit_pos: %0d | k[bit_pos] = %b\n", $time, uut.bit_pos, k[uut.bit_pos]);
            $fwrite(file, "  Updated R0: X0 = %h, Y0 = %h, Z0 = %h\n", uut.X0, uut.Y0, uut.Z0);
            $fwrite(file, "  Updated R1: X1 = %h, Y1 = %h, Z1 = %h\n\n", uut.X1, uut.Y1, uut.Z1);
        end
    end

    initial begin
        // Mở tệp để ghi kết quả
        file = $fopen("01_tb/output_scalar.txt", "w");
        if (file == 0) begin
            $display("Error: Could not open output file.");
            $finish;
        end

        clk = 0; 
        rst_n = 0;
        start = 0;
        k = 256'h3E9F128209B8F412C2874E2F6656446BE30138B748B9E18401EE9BABC5CE923F;
        X = 256'h79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798;
        Y = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
        Z = 256'h0000000000000000000000000000000000000000000000000000000000000001;
        p = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;

        #20 rst_n = 1;
        #20 start = 1;

        wait(o_done);
        $display("Scalar Multiplication Complete:");
        $display("X_out = %h", X_out);
        $display("Y_out = %h", Y_out);
        $display("Z_out = %h", Z_out);

        // Ghi kết quả cuối cùng vào tệp
        $fwrite(file, "Scalar Multiplication Complete:\n");
        $fwrite(file, "X_out = %h\n", X_out);
        $fwrite(file, "Y_out = %h\n", Y_out);
        $fwrite(file, "Z_out = %h\n", Z_out);

        // Đóng tệp
        $fclose(file);

        #2000;
        $finish;
    end
endmodule