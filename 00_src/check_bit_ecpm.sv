module check_bit_ecpm (
    input logic [255:0] data_in,
    output logic [8:0] first_one_position,
    output logic found
);

    always_comb begin
        first_one_position = -1; // Giá trị mặc định nếu không tìm thấy
        found = 0;
        for (int i = 255; i >= 0; i--) begin
            if (data_in[i]) begin
                first_one_position = i;
                found = 1;
                break; // Dừng lại sau khi tìm thấy bit 1 đầu tiên
            end
        end
    end

endmodule