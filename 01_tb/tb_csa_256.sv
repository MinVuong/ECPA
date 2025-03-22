`timescale 1ns / 1ps

module tb_csa_256;

    // Khai báo các tín hiệu đầu vào và đầu ra
    reg [255:0] a, b, c;
    reg start;
    reg clk;
    wire [256:0] s;
    wire cout;
    wire done;

    // Khởi tạo mô-đun csa_256
    csa_256 uut (
        .a(a),
        .b(b),
        .c(c),
        .start(start),
        .clk(clk),
        .s(s),
        .cout(cout),
        .done(done)
    );

    // Tạo xung đồng hồ
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Tạo xung clock với chu kỳ 10ns
    end

    // Khai báo biến để lưu tổng lý thuyết
    reg [256:0] expected_s;
    reg expected_cout;

    initial begin
        // Khởi tạo tín hiệu
        start = 0;

        // Thời gian bắt đầu
        $display("Time\t\tA\t\t\tB\t\t\tC\t\t\ts\t\t\tCout\t\tExpected s\tExpected Cout\tTest Result");
        
        // Test case 1: 125 + 421 + 15
        a = 256'd125;
        b = 256'd421;
        c = 256'd15;
        expected_s = 256'd561; // 125 + 421 + 15 = 561
        expected_cout = 0; // Không có carry-out
        #10 start = 1; // Bắt đầu tính toán
        #10 start = 0; // Đặt lại tín hiệu start
        wait_for_done;

        // Test case 2: Max unsigned 256-bit + Max + 1
       a= 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // Max value
        b = 256'h0000000000000000000000000000000000000000000000000000000000000002; // 2
        c = 256'h0000000000000000000000000000000000000000000000000000000000000003; // 3
        expected_s = 256'h0000000000000000000000000000000000000000000000000000000000000004; // 2 + 1 = 3
        expected_cout = 1; // Có carry-out
        #10 start = 1; // Bắt đầu tính toán
        #10 start = 0; // Đặt lại tín hiệu start
        wait_for_done;

        // Test case 3: Phép cộng lớn
        a = 256'h1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF;
        b = 256'hFEDCBA0987654321FEDCBA0987654321FEDCBA0987654321FEDCBA0987654321;
        c = 256'h1111111111111111111111111111111100000000000000000000000000000000;
        expected_s = 256'h2222219329222222222221932922222211111082181111111111108218111110
; // Kết quả lý thuyết
        expected_cout = 1; // Giả định không có carry-out
        #10 start = 1; // Bắt đầu tính toán
        #10 start = 0; // Đặt lại tín hiệu start
        wait_for_done;

        // Test case 4: 3125 + 1421 + 155
        a = 256'd3125;
        b = 256'd1421;
        c = 256'd155;
        expected_s = 256'd4701; // 3125 + 1421 + 155 = 4701
        expected_cout = 0; // Không có carry-out
        #10 start = 1; // Bắt đầu tính toán
        #10 start = 0; // Đặt lại tín hiệu start
        wait_for_done;

        // Test case 5: 0 + 0 + 0
        a = 256'd0;
        b = 256'd0;
        c = 256'd0;
        expected_s = 256'd0; // 0 + 0 + 0 = 0
        expected_cout = 0; // Không có carry-out
        #10 start = 1; // Bắt đầu tính toán
        #10 start = 0; // Đặt lại tín hiệu start
        wait_for_done;

        // Kết thúc mô phỏng
        $finish;
    end

    // Hàm chờ cho tín hiệu done
    task wait_for_done;
        begin
            wait(done); // Chờ cho tín hiệu done được bật lên
            // Kiểm tra kết quả
            if (s !== expected_s || cout !== expected_cout) begin
                $display("Test Failed: %d + %d + %d = %d (Cout: %b) | Expected: %d (Cout: %b)", a, b, c, s, cout, expected_s, expected_cout);
            end else begin
                $display("Test Passed: %d + %d + %d = %d (Cout: %b)", a, b, c, s, cout);
            end
        end
    endtask

endmodule