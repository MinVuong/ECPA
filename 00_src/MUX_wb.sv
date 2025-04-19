module MUX_wb(
    input  logic [1:0]  wb_sel,         
    input  logic [255:0] ecpm_x, ecpm_y, ecpm_z,
    input  logic [255:0] ecc_x, ecc_y, ecc_z,
    input  logic [255:0] ecpa_x, ecpa_y, ecpa_z,
    // input  logic [255:0] ecpd_x, ecpd_y, ecpd_z,
    output logic [255:0] wb_data_1, wb_data_2, wb_data_3
);

    always_comb begin
        case (wb_sel)
            2'b00: begin
                wb_data_1 = ecpm_x;
                wb_data_2 = ecpm_y;
                wb_data_3 = ecpm_z;
            end
            2'b01: begin
                wb_data_1 = ecc_x;
            //    wb_data_2 = ecc_y;
            //    wb_data_3 = ecc_z;
            end
            2'b10: begin
                wb_data_1 = ecpa_x;
                wb_data_2 = ecpa_y;
                wb_data_3 = ecpa_z;
            end
            /*
            2'b11: begin
                wb_data_1 = ecpd_x;
                wb_data_2 = ecpd_y;
                wb_data_3 = ecpd_z;
            end */
            default: begin
                wb_data_1 = 256'b0;
                wb_data_2 = 256'b0;
                wb_data_3 = 256'b0;
            end
        endcase
    end

endmodule
