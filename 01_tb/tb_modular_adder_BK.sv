//`timescale 1ns / 1ps

module tb_modular_adder_BK;

    // Khai báo các tín hiệu
    reg clk;
    reg rst_n;
    reg start;
    reg [255:0] A;
    reg [255:0] B;
    reg [255:0] P;
    wire done_add;
    wire [255:0] R;

    // Khai báo module cần kiểm tra
    modular_adder_BK uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .A(A),
        .B(B),
        .P(P),
        .done_add(done_add),
        .R(R)
    );

    // Tạo xung đồng hồ
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Tạo xung đồng hồ với chu kỳ 10ns
    end

    // Khởi tạo tín hiệu và kiểm tra
    initial begin
        // Khởi động reset
        rst_n = 0;
        start = 0;
        A = 0;
        B = 0;
        P = 0;
        #10; // Đợi 10ns

        rst_n = 1; // Bỏ reset
        
        // Test case 1
        A = 256'h00000000000000000000000000000001; // A = 1
        B = 256'h00000000000000000000000000000002; // B = 2
        P = 256'h00000000000000000000000000000003; // P = 3
        start = 1; // Bắt đầu phép cộng
        #10; // Đợi 10ns
        start = 0; // Dừng tín hiệu start

        // Đợi kết quả
        wait(done_add);
        #10; // Chờ thêm 10ns để kiểm tra kết quả
        $display("Test case 1: R = %h, done_add = %b", R, done_add);

        // Test case 2
        A = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // A = 2^256 - 1
        B = 256'h00000000000000000000000000000001; // B = 1
        P = 256'h00000000000000000000000000000000; // P = 0 (trường hợp đặc biệt)
        start = 1; // Bắt đầu phép cộng
        #10;
        start = 0;

        // Đợi kết quả
        wait(done_add);
        #10; // Chờ thêm 10ns để kiểm tra kết quả
        $display("Test case 2: R = %h, done_add = %b", R, done_add);

        // Test case 3
        A = 256'h00000000000000000000000000000005; // A = 5
        B = 256'h00000000000000000000000000000003; // B = 3
        P = 256'h00000000000000000000000000000007; // P = 7
        start = 1; // Bắt đầu phép cộng
        #10;
        start = 0;

        // Đợi kết quả
        wait(done_add);
        #10; // Chờ thêm 10ns để kiểm tra kết quả
        $display("Test case 3: R = %h, done_add = %b", R, done_add);

        // Kết thúc mô phỏng
        #1000;
        $finish;
    end

endmodule
