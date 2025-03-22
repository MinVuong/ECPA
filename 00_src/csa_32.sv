module csa_32 (
    input clk, rst_n,            // Clock and active-low reset
    input [31:0] a, b, c,
    output reg [32:0] s,
    output reg cout
);

    reg [31:0] s1_reg, c1_reg, c2_reg; // Đăng ký trung gian cho các giai đoạn
    reg [32:0] s_reg; // Đăng ký đầu ra
    reg cout_reg;

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1_reg <= 32'b0;
            c1_reg <= 32'b0;
        end else begin
            // Giai đoạn cộng 1 bit (Dùng Non-Blocking)
            for (i = 0; i < 32; i = i + 1) begin
                {c1_reg[i], s1_reg[i]} <= a[i] + b[i] + c[i]; // Sửa "=" thành "<="
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            c2_reg <= 32'b0;
            s_reg <= 33'b0;
            cout_reg <= 1'b0;
        end else begin
            // Giai đoạn cộng các bit trung gian (Dùng Non-Blocking)
            s_reg[0] <= s1_reg[0]; // Bit đầu tiên
            {c2_reg[1], s_reg[1]} <= s1_reg[1] + c1_reg[0]; // Sửa "=" thành "<="
            for (i = 2; i < 32; i = i + 1) begin
                {c2_reg[i], s_reg[i]} <= s1_reg[i] + c1_reg[i-1] + c2_reg[i-1]; // Sửa "=" thành "<="
            end
            {cout_reg, s_reg[32]} <= s1_reg[31] + c1_reg[31] + c2_reg[31]; // Sửa "=" thành "<="
        end
    end

    // Cập nhật đầu ra sau mỗi chu kỳ clock
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s <= 33'b0;
            cout <= 1'b0;
        end else begin
            s <= s_reg;
            cout <= cout_reg;
        end
    end

endmodule
