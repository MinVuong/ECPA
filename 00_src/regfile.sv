module regfile (
    input logic i_clk,              // Clock
    input logic i_rst_n,            // Active-low reset
    input logic [4:0] rs1_addr,     // Địa chỉ đọc cho rs1
    input logic [4:0] rs2_addr,     // Địa chỉ đọc cho rs2
    input logic [4:0] wb_addr,      // Địa chỉ ghi
    input logic [255:0] wb_data_1,  // Dữ liệu ghi 1 (256 bit)
    input logic [255:0] wb_data_2,  // Dữ liệu ghi 2 (256 bit)
    input logic [255:0] wb_data_3,  // Dữ liệu ghi 3 (256 bit)
    input logic [1:0] ecc_control,  // Tín hiệu điều khiển chế độ
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
                2'b00: begin
                    rs1x_data = memory[rs1_addr];
                    rs2x_data = memory[rs2_addr];
                end
                2'b01: begin
                    rs1x_data = memory[rs1_addr];
                    rs1y_data = memory[rs1_addr + 5'd1];
                    rs1z_data = memory[rs1_addr + 5'd2];
                    rs2x_data = memory[rs2_addr];
                    rs2y_data = memory[rs2_addr + 5'd1];
                    rs2z_data = memory[rs2_addr + 5'd2];
                end
                2'b10: begin
                    rs1x_data = memory[rs1_addr];
                    rs2x_data = memory[rs2_addr];
                    rs2y_data = memory[rs2_addr + 5'd1];
                    rs2z_data = memory[rs2_addr + 5'd2];
                end
                2'b11: begin
                    rs1x_data = memory[rs1_addr];
                    rs1y_data = memory[rs1_addr + 5'd1];
                    rs1z_data = memory[rs1_addr + 5'd2];
                    rs2x_data = memory[rs2_addr];
                    rs2y_data = memory[rs2_addr + 5'd1];
                    rs2z_data = memory[rs2_addr + 5'd2];
                end
            endcase
        end
    end

    // Logic ghi và reset (sequential)
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            // Reset: gán giá trị ban đầu cho các thanh ghi
            memory[0] <= 256'd0;     // Thanh ghi 0 luôn là 0
            memory[1] <= 256'd1;     // Thanh ghi 1 = 1
            memory[2] <= 256'd2;     // Thanh ghi 2 = 2
            memory[3] <= 256'd3;     // Thanh ghi 3 = 3
            memory[4] <= 256'd4;     // Thanh ghi 4 = 4
            memory[5] <= 256'd5;     // Thanh ghi 5 = 5
            memory[6] <= 256'd6;     // Thanh ghi 6 = 6
            // Đặt các thanh ghi còn lại (7 đến 31) về 0
            for (int i = 7; i < 32; i = i + 1) begin
                memory[i] <= 256'd0;
            end
        end else if (write) begin
            // Đảm bảo thanh ghi 0 luôn là 0
            memory[0] <= 256'd0;

            // Xử lý các trường hợp ghi dựa trên ecc_control
            case (ecc_control)
                2'b00: begin
                    memory[wb_addr] <= wb_data_1;
                end
                2'b01: begin
                    memory[wb_addr] <= wb_data_1;
                    memory[wb_addr + 5'd1] <= wb_data_2;
                    memory[wb_addr + 5'd2] <= wb_data_3;
                end
                2'b10: begin
                    memory[wb_addr] <= wb_data_1;
                end
                2'b11: begin
                    memory[wb_addr] <= wb_data_1;
                end
            endcase
        end
    end

endmodule