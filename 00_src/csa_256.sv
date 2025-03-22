module csa_256
    (   input [255:0] a, b, c,
        output [256:0] s,
        output cout
    );

    wire [255:0] s1, c1, c2; // Các tín hiệu trung gian cho từng giai đoạn
    
    // Giai đoạn cộng 1 bit
    genvar i;
    generate
        for (i = 0; i < 256; i = i + 1) begin : adder_stage1
            fulladder fa_inst(
                .a(a[i]),
                .b(b[i]),
                .c(c[i]),
                .s(s1[i]),
                .cout(c1[i])
            );
        end
    endgenerate

    // Giai đoạn cộng các bit trung gian
     fulladder fa_inst20(s1[1], c1[0], 1'b0, s[1], c2[1]); // Bit đầu tiên, c vào là 1'b0
    generate
        for (i = 2; i < 256; i = i + 1) begin : adder_stage2
            fulladder fa_inst2(
                .a(s1[i]),
                .b(c1[i-1]),
                .c(c2[i-1]), // Gán c bằng cout của bộ trước
                .s(s[i]),
                .cout(c2[i])
            );
        end
    endgenerate

    // Xử lý bit cuối
    fulladder fa_inst_last(
        .a(s1[255]),
        .b(c1[255]),
        .c(c2[255]),
        .s(s[256]),
        .cout(cout)
    );

    // Bit đầu tiên
    assign s[0] = s1[0];

endmodule