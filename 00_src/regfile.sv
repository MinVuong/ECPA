module regfile (
    input logic i_clk,              // Clock
    input logic i_rst_n,            // Active-low reset
    input logic [4:0] rs1_addr,     // Địa chỉ đọc cho rs1
    input logic [4:0] rs2_addr,     // Địa chỉ đọc cho rs2
    input logic [4:0] wb_addr,      // Địa chỉ ghi
    input logic [255:0] wb_data_1,  // Dữ liệu ghi 1 (256 bit)
    input logic [255:0] wb_data_2,  // Dữ liệu ghi 2 (256 bit)
    input logic [255:0] wb_data_3,  // Dữ liệu ghi 3 (256 bit)
    input logic [2:0] ecc_control,  // Tín hiệu điều khiển chế độ
    input logic wb_wren,            // Tín hiệu cho phép ghi
    output logic [255:0] rs1x_data, // Dữ liệu đọc rs1x (256 bit)
    output logic [255:0] rs1y_data, // Dữ liệu đọc rs1y (256 bit)
    output logic [255:0] rs1z_data, // Dữ liệu đọc rs1z (256 bit)
    output logic [255:0] rs2x_data, // Dữ liệu đọc rs2x (256 bit)
    output logic [255:0] rs2y_data, // Dữ liệu đọc rs2y (256 bit)
    output logic [255:0] rs2z_data  // Dữ liệu đọc rs2z (256 bit)
);

    // Khai báo bộ nhớ regfile: 32 thanh ghi, mỗi thanh ghi 256 bit
    logic [255:0] memory [0:31];
    logic write;
    logic not_reg0;

    // Kiểm tra nếu địa chỉ ghi không phải là thanh ghi 0
    assign not_reg0 = (|wb_addr); // Tín hiệu = 1 nếu wb_addr != 0

    // Điều kiện ghi: chỉ ghi khi wb_wren = 1 và không ghi vào thanh ghi 0
    assign write = wb_wren & not_reg0;

    // Logic đọc (combinational)
    always_comb begin
        // Mặc định các đầu ra là 0 nếu không đọc
        rs1x_data = 256'd0;
        rs1y_data = 256'd0;
        rs1z_data = 256'd0;
        rs2x_data = 256'd0;
        rs2y_data = 256'd0;
        rs2z_data = 256'd0;

        // Xử lý các trường hợp đọc dựa trên ecc_control và wb_wren
        if (!wb_wren) begin
            case (ecc_control)
                3'b010: begin
                    rs1x_data = memory[rs1_addr];
                    rs2x_data = memory[rs2_addr];
                end
                3'b001: begin
                    rs1x_data = memory[rs1_addr];

                    rs2x_data = memory[rs2_addr];
                    rs2y_data = memory[rs2_addr + 5'd1];
                    rs2z_data = memory[rs2_addr + 5'd2];
                end
                3'b000: begin
                    rs1x_data = memory[rs1_addr];
                    rs2x_data = memory[rs2_addr];
                    rs2y_data = memory[rs2_addr + 5'd1];
                    rs2z_data = memory[rs2_addr + 5'd2];
                end
                3'b011: begin
                    rs1x_data = memory[rs1_addr];
                    rs1y_data = memory[rs1_addr + 5'd1];
                    rs1z_data = memory[rs1_addr + 5'd2];
                    rs2x_data = memory[rs2_addr];
                    rs2y_data = memory[rs2_addr + 5'd1];
                    rs2z_data = memory[rs2_addr + 5'd2];
                end
                3'b100: begin
                    rs1x_data = memory[rs1_addr];
                    rs1y_data = memory[rs1_addr + 5'd1];
                    rs1z_data = memory[rs1_addr + 5'd2];
                end
            endcase
        end
    end

    // Logic ghi và reset (sequential)
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            // Reset: gán giá trị ban đầu cho các thanh ghi
            memory[0] <= 256'd0;     // Thanh ghi 0 luôn là 0
            memory[1] <= 256'h36AF1F408263958E69A9E4B22647594A4C502F449B3C6949A7A995309A00E917;     // Thanh ghi 1 = hash_m
            memory[2] <= 256'h16AACD4BA074939022CB12DC92468BB0266E0687881D2BA0C18476DC2A910167;     // Thanh ghi 2 = k 
            memory[3] <= 256'h4CD4F18D4406D717313B49FAC61F96233E4A32749E244B23B516EDD04B41015B;     // Thanh ghi 3 = d 
            memory[4] <= 256'h79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798;     // Thanh ghi 4 = Xg
            memory[5] <= 256'h483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8;     // Thanh ghi 5 = yg
            memory[6] <= 256'h1;     // Thanh ghi 6 = zg
            // Đặt các thanh ghi còn lại (7 đến 31) về 0
            for (int i = 7; i < 32; i = i + 1) begin
                memory[i] <= 256'd0;
            end
        end else if (write) begin
            // Đảm bảo thanh ghi 0 luôn là 0
            memory[0] <= 256'd0;

            // Xử lý các trường hợp ghi dựa trên ecc_control
            case (ecc_control)
                3'b000: begin
                    memory[wb_addr] <= wb_data_1;
                end
                3'b001: begin
                    memory[wb_addr] <= wb_data_1;
                    memory[wb_addr + 5'd1] <= wb_data_2;
                    memory[wb_addr + 5'd2] <= wb_data_3;
                 
                end
                3'b010: begin
                    memory[wb_addr] <= wb_data_1;
                end
                3'b011: begin
                    memory[wb_addr] <= wb_data_1;
                    memory[wb_addr + 5'd1] <= wb_data_2;
                    memory[wb_addr + 5'd2] <= wb_data_3;
                end
                3'b100: begin
                    memory[wb_addr] <= wb_data_1;
                
                end
            endcase
        end
    end

endmodule