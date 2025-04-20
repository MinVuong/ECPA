module ECC_top (
    input  logic i_clk,
    input  logic i_rst_n, 
    input  logic i_start,

   // output logic verify,
   // output logic [255:0] sig_r,
   // output logic [255:0] sig_s,
   output logic done
);
    logic [255:0] p, n;
    assign p = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
    assign n = 256'hfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141;

    // ===== PC and PC+4 =====
    logic [31:0] pc, pc_next;
    logic [255:0] wb_data_1, wb_data_2, wb_data_3;
    logic [31:0] inst;
//---------------------------------------------------------------
//Logic control unit
    logic start_ECPM, start_ECC_core, start_ECPA, start_affine;
    logic [1:0] wb_sel;
    logic [2:0] ecc_sel;        
    logic en_pc_update;
    logic wb_wren;
    logic [2:0] ecc_control;
//---------------------------------------------------------------
// Logic Regfile
    logic [255:0] rs1x_data, rs1y_data, rs1z_data;
    logic [255:0] rs2x_data, rs2y_data, rs2z_data;
//---------------------------------------------------------------
// Logic ECC
//    logic [255:0] ECC_top_X, ECC_top_Y, ECC_top_Z;
    logic [255:0] ecpm_X, ecpm_Y, ecpm_Z;
   // logic [255:0] ecc_out;
    // ECPA
    logic done_ECPA;
    logic [255:0] ecpa_X, ecpa_Y, ecpa_Z;
    // ECPM
    logic done_ECPM;
    //logic [255:0] ecpm_X, ecpm_Y, ecpm_Z;
//---------------------------------------------------------------
// Logic ECC_core
    logic [255:0] ecc_X;
    logic done_ECC_core;
// Logic affine 
    logic [255:0] affine_x, affine_y;
    logic done_affine;
    logic [255:0] jacobian_x, jacobian_y, jacobian_z;
    assign jacobian_x = (ecc_control == 3'b001) ? ecpm_X : ecpa_X;
    assign jacobian_y = (ecc_control == 3'b001) ? ecpm_Y : ecpa_Y;
    assign jacobian_z = (ecc_control == 3'b001) ? ecpm_Z : ecpa_Y;





    pc pc_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_en_pc_update(en_pc_update),
        .i_pc(pc_next),
        .o_pc(pc)   
    );

    pc_4 pc_plus4 (
        .i_pc_in(pc),
        .o_pc_out(pc_next)
    );

    // ===== Instruction Memory =====
    

    imem imem_inst (
        .addr(pc),
        .inst(inst)
    );

    // ===== Control Unit =====
    //logic done_inst;
 

    control_unit    control_inst (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(i_start), 
        .instruction(inst),
        .done_ECPM(done_ECPM),
        .done_affine(done_affine),
        .done_ECC_core(done_ECC_core),
        .done_ECPA(done_ECPA),
        .start_ECPM(start_ECPM),
        .start_affine(start_affine),
        .start_ECC_core(start_ECC_core),
        .start_ECPA(start_ECPA),
        .wb_sel(wb_sel),
        .ecc_sel(ecc_sel),
        .ecc_control(ecc_control),
        .wb_wren(wb_wren),
        .en_pc_update(en_pc_update),
        .done(done)
    );

   

    // ===== ECC Modules =====

   

    
    ECPA ecpa_inst (
       .i_clk(i_clk),
       .i_rst_n(i_rst_n),
       .i_start(start_ECPA),
       .p(p),
       .X1(rs1x_data), .Y1(rs1y_data), .Z1(rs1z_data),
       .X2(rs2x_data), .Y2(rs2y_data), .Z2(rs2z_data),  
       .X3(ecpa_X), .Y3(ecpa_Y), .Z3(ecpa_Z),
       .o_done(done_ECPA)
    );

    // ECPM 
  
    ECPM ecpm_inst (
         .i_clk(i_clk),
         .i_rst_n(i_rst_n),
         .i_start(start_ECPM),
         .p(p),
         .k(rs1x_data),
         .X(rs2x_data), .Y(rs2y_data), .Z(rs2z_data),
         .X_out(ecpm_X), .Y_out(ecpm_Y), .Z_out(ecpm_Z),
         .o_done(done_ECPM)
    
    );
//  ECC_core
 
    ECC_core ecc_core_inst (
        .start(start_ECC_core),
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .a(rs1x_data), 
        .b(rs2x_data), 
        .prime(p),
        .n(n), 
        .ecc_sel(ecc_sel),
        .alu_result(ecc_X),
        .done(done_ECC_core)
    );

    // ===== Affine Conversion =====
    Jacobian_to_Affine jacobian_to_affine_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_start(start_affine),
        .X_Jacobian(jacobian_x), .Y_Jacobian(jacobian_y), .Z_Jacobian(jacobian_z),
        .p(p),
        .X_Affine(affine_x), .Y_Affine(affine_y),
        .o_done(done_affine)
    );
    //Mux 4->1

    MUX_wb mux_wb_inst (
        .wb_sel(wb_sel),
        .ecpm_x(ecpm_X), .ecpm_y(ecpm_Y), .ecpm_z(ecpm_Z),
        .ecc_x(ecc_X), .ecc_y(256'd0), .ecc_z(256'd0),
        .ecpa_x(ecpa_X), .ecpa_y(ecpa_Y), .ecpa_z(ecpa_Z),
        .affine_x(affine_x), .affine_y(affine_y),
        //.ecpd_x(ecpd_X), .ecpd_y(ecpd_Y), .ecpd_z(ecpd_Z),
        .wb_data_1(wb_data_1), .wb_data_2(wb_data_2), .wb_data_3(wb_data_3)
    );

     // ===== Register File =====


    regfile regfile_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .rs1_addr(inst[19:15]), 
        .rs2_addr(inst[24:20]),
        .wb_addr(inst[11:7]),
        .wb_data_1(wb_data_1), 
        .wb_data_2(wb_data_2), 
        .wb_data_3(wb_data_3), 
        .ecc_control(ecc_control), 
        .wb_wren(wb_wren), 
        .rs1x_data(rs1x_data), 
        .rs1y_data(rs1y_data),
        .rs1z_data(rs1z_data),
        .rs2x_data(rs2x_data), 
        .rs2y_data(rs2y_data), 
        .rs2z_data(rs2z_data)
      
    );
   

endmodule
