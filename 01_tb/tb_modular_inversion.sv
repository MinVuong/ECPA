`timescale 1ns / 1ps
module tb_modular_inversion;

    // Khai báo tín hiệu
    reg clk;
    reg rst_n;
    reg start;
    reg [255:0] b, a, m;
    wire [255:0] c;
    wire ready;
   // wire busy;
   // wire ready0;

    // Khởi tạo mô-đun
    modular_inversion uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .b(b),
        .a(a),
        .m(m),
        .c(c),
        .ready(ready)
        //.busy(busy),
        //.ready0(ready0)
    );

    // Tạo tín hiệu đồng hồ
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Thay đổi trạng thái mỗi 5ns
    end

    // Quy trình test
    initial begin
        // Khởi tạo
        rst_n = 0;
        start = 0;
        
	a = 256'h00000000000000000000000000000000000000000000000000000000000000be;
    b = 256'd1;
	m = 256'd367;
        //expected_result = 255'h0;
        
        // Thời gian reset
        #20;
        rst_n = 1; // Bỏ reset

        // Bắt đầu phép toá
        start = 1; // Kích hoạt phép toán
       
        // Chờ kết quả
        wait(ready); // Chờ cho ready được kích hoạt

        // In kết quả
        #10;
        $display("Result: c = %h", c);
      //  $display("Ready: %b, Busy: %b", ready, busy);
       // if (expected_result == c) $display("Verified succeeded");
       // else $display("Verified not succeeded");

        // Kết thúc mô phỏng
        #20;
        $finish;
    end

endmodule