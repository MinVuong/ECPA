module ECPA (
    input         i_clk,
    input         i_rst_n,
    input         i_start,
    input  [255:0] p,
    // P = (X1, Y1, Z1)
    input  [255:0] X1,
    input  [255:0] Y1,
    // input  [255:0] Z1,
    // Q = (X2, Y2, Z2)
    input  [255:0] X2,
    input  [255:0] Y2,
   // input  [255:0] Z2,
    // R = (X3_J, Y3_J, Z3_J)
    output logic [255:0] X3,
    output logic [255:0] Y3,
    // output logic [255:0] Z3_J,
    output logic         o_done
);
logic [255:0] Z1, Z2, Z3_J;
assign Z1 = 256'h1;
assign Z2 = 256'h1;
//-----------------------------------------------//
// Stage 1
//-----------------------------------------------//
 logic start_stage1;
 logic done_stage1;
 logic done_Z1_Z2, done_Z1_SQ, done_Z2_SQ ;
 logic [255:0] Z1_Z2, Z1_SQ, Z2_SQ;
// assign start_stage1 = i_start;

logic start_pulse_stage1, start_d_stage1;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        start_d_stage1   <= 1'b0;
        start_pulse_stage1 <= 1'b0;
    end else begin
        start_d_stage1   <= i_start;                   // Lưu giá trị trước của i_start
        start_pulse_stage1 <= i_start & ~start_d_stage1;      // Chỉ bật khi i_start chuyển từ 0 -> 1
    end
end
assign start_stage1 = start_pulse_stage1;

//Z1Z2
 modular_multiplication mult10 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage1),
        .a(Z1),
        .b(Z2),
        .m(p),
        .p(Z1_Z2),
        .ready(done_Z1_Z2)
    );
// Z1_SQ

modular_multiplication mult11 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage1),
        .a(Z1),
        .b(Z1),
        .m(p),
        .p(Z1_SQ),
        .ready(done_Z1_SQ)
    );
//Z2_SQ
modular_multiplication mult12 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage1),
        .a(Z2),
        .b(Z2),
        .m(p),
        .p(Z2_SQ),
        .ready(done_Z2_SQ)
    );
  assign done_stage1 = done_Z1_SQ&done_Z2_SQ&done_Z1_Z2;

//----------------------------------------//
// Stage 2
//----------------------------------------//
logic start_stage2;
 logic done_stage2;
 logic done_Z1_cube, done_U1, done_U2, done_Z2_cube ;
 logic [255:0] Z1_cube, Z2_cube, U1, U2;
logic start_pulse_stage2, start_d_stage2;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        start_d_stage2   <= 1'b0;
        start_pulse_stage2 <= 1'b0;
    end else begin
        start_d_stage2   <= done_stage1;                   // Lưu giá trị trước của i_start
        start_pulse_stage2 <= done_stage1 & ~start_d_stage2;      // Chỉ bật khi i_start chuyển từ 0 -> 1
    end
end
assign start_stage2 = start_pulse_stage2;

//Z1_cube
 modular_multiplication mult20 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage2),
        .a(Z1_SQ),
        .b(Z1),
        .m(p),
        .p(Z1_cube),
        .ready(done_Z1_cube)
    );
// Z2_cube
modular_multiplication mult21 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage2),
        .a(Z2_SQ),
        .b(Z2),
        .m(p),
        .p(Z2_cube),
        .ready(done_Z2_cube)
    );
//U1
modular_multiplication mult22 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage2),
        .a(X1),
        .b(Z2_SQ),
        .m(p),
        .p(U1),
        .ready(done_U1)
    );
//U2
modular_multiplication mult23 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage2),
        .a(X2),
        .b(Z1_SQ),
        .m(p),
        .p(U2),
        .ready(done_U2)
    );

  assign done_stage2 = done_Z1_cube&done_Z2_cube&done_U1&done_U2;

//-----------------------------------------------//
// Stage 3
//-----------------------------------------------//
 logic start_stage3;
 logic done_stage3;
 logic done_S1, done_S2, done_H ;
 logic [255:0] S1, S2, H;
 //assign start_stage3 = done_stage2;
 logic start_pulse_stage3, start_d_stage3;
 //logic start_stage3_sub;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        start_d_stage3   <= 1'b0;
        start_pulse_stage3 <= 1'b0;
    end else begin
        start_d_stage3   <= done_stage2;                   // Lưu giá trị trước của i_start
        start_pulse_stage3 <= done_stage2 & ~start_d_stage3;      // Chỉ bật khi i_start chuyển từ 0 -> 1
    end
end
assign start_stage3 = start_pulse_stage3;
//assign start_stage3_sub= done_stage2;
reg start_stage3_sub;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
        start_stage3_sub <= 0;
    else if (done_stage2)  // Bắt đầu instance sub khi stage 1 hoàn thành
        start_stage3_sub <= 1;
    else if (done_H)  // Tắt khi instance sub hoàn thành
        start_stage3_sub <= 0;
end


//S1 = Y1*Z2_cube
 modular_multiplication mult30 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage3),
        .a(Y1),
        .b(Z2_cube),
        .m(p),
        .p(S1),
        .ready(done_S1)
    );
// S2= Y2*Z1_cube 
modular_multiplication mult31 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage3),
        .a(Y2),
        .b(Z1_cube),
        .m(p),
        .p(S2),
        .ready(done_S2)
    );
//h = U1-U22
modular_subtractor sub32(
	.i_start(start_stage3_sub),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.A(U1),
	.B(U2),
	.p(p),
	.result(H),
	.done(done_H)
);
  assign done_stage3 = done_S1&done_S2&done_H;

//-----------------------------------------------//
// Stage 4
//-----------------------------------------------//
 logic start_stage4;
 logic done_stage4;
 logic done_R, done_Z3_J, done_H_SQ ;
 logic [255:0] R, H_SQ;
 //assign start_stage4 = done_stage3;
 logic start_pulse_stage4, start_d_stage4;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        start_d_stage4   <= 1'b0;
        start_pulse_stage4 <= 1'b0;
    end else begin
        start_d_stage4   <= done_stage3;                   // Lưu giá trị trước của i_start
        start_pulse_stage4 <= done_stage3 & ~start_d_stage4;      // Chỉ bật khi i_start chuyển từ 0 -> 1
    end
end
assign start_stage4 = start_pulse_stage4;
// chú ý control chỗ trừ và nhân tại nhân thì chỉ cần start 1 clock còn cộng trừ thì bật lun

reg start_stage4_sub;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
        start_stage4_sub <= 0;
    else if (done_stage3)  // Bắt đầu instance sub khi stage 1 hoàn thành
        start_stage4_sub <= 1;
    else if (done_R)  // Tắt khi instance sub hoàn thành
        start_stage4_sub <= 0;
end
//R=S1-S2
modular_subtractor sub40(
	.i_start(start_stage4_sub),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.A(S1),
	.B(S2),
	.p(p),
	.result(R),
	.done(done_R)
);

// Z3_J = Z1Z2*H
 modular_multiplication mult41 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage4),
        .a(Z1_Z2),
        .b(H),
        .m(p),
        .p(Z3_J),
        .ready(done_Z3_J)
    );
// H_SQ 
 modular_multiplication mult42 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage4),
        .a(H),
        .b(H),
        .m(p),
        .p(H_SQ),
        .ready(done_H_SQ)
    );

  assign done_stage4 = done_R&done_Z3_J&done_H_SQ;

//-----------------------------------------------//
// Stage 5
//-----------------------------------------------//
 logic start_stage5;
 logic done_stage5;
 logic done_V, done_H_cube, done_R_SQ ;
 logic [255:0] V,H_cube, R_SQ;
 //assign start_stage5 = done_stage4;
 logic start_pulse_stage5, start_d_stage5;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        start_d_stage5   <= 1'b0;
        start_pulse_stage5 <= 1'b0;
    end else begin
        start_d_stage5   <= done_stage4;                   // Lưu giá trị trước của i_start
        start_pulse_stage5 <= done_stage4 & ~start_d_stage5;      // Chỉ bật khi i_start chuyển từ 0 -> 1
    end
end
assign start_stage5 = start_pulse_stage5;

// V = U1*H_SQ
  modular_multiplication mult50 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage5),
        .a(U1),
        .b(H_SQ),
        .m(p),
        .p(V),
        .ready(done_V)
    );

// H_cube
  modular_multiplication mult51 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage5),
        .a(H_SQ),
        .b(H),
        .m(p),
        .p(H_cube),
        .ready(done_H_cube)
    );
// R_SQ
 modular_multiplication mult52 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage5),
        .a(R),
        .b(R),
        .m(p),
        .p(R_SQ),
        .ready(done_R_SQ)
    );

  assign done_stage5 = done_V&done_H_cube&done_R_SQ;

//-----------------------------------------------//
// Stage 6
//-----------------------------------------------//
 logic start_stage6;
 logic done_stage6;
 logic done_twoV, done_R_SQ_ADD_G ;
 logic [255:0] twoV, R_SQ_ADD_G;
 //assign start_stage6 = done_stage5;
 logic start_pulse_stage6, start_d_stage6;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        start_d_stage6   <= 1'b0;
        start_pulse_stage6 <= 1'b0;
    end else begin
        start_d_stage6   <= done_stage5;                   // Lưu giá trị trước của i_start
        start_pulse_stage6 <= done_stage5 & ~start_d_stage6;      // Chỉ bật khi i_start chuyển từ 0 -> 1
    end
end
assign start_stage6 = start_pulse_stage6;

reg start_stage6_add;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
        start_stage6_add <= 0;
    else if (done_stage5)  // Bắt đầu instance sub khi stage 1 hoàn thành
        start_stage6_add <= 1;
    else if (done_R_SQ_ADD_G)  // Tắt khi instance sub hoàn thành
        start_stage6_add <= 0;
end

// 2V
  modular_multiplication mult60 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage6),
        .a(256'h2),
        .b(V),
        .m(p),
        .p(twoV),
        .ready(done_twoV)
    );

// R_SQ + G
 modular_addition add61(
	.i_start(start_stage6_add),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.A(R_SQ),
	.B(H_cube),
	.p(p),
	.result(R_SQ_ADD_G),
	.done(done_R_SQ_ADD_G)
);
  assign done_stage6 = done_twoV&done_R_SQ_ADD_G;

//-----------------------------------------------//
// Stage 7
//-----------------------------------------------//
 logic start_stage7;
 logic done_stage7;
 logic done_X3_J ;
 logic [255:0] X3_J;
 //assign start_stage7 = done_stage6;
reg start_stage7_sub;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
        start_stage7 <= 0;
    else if (done_stage6)  // Bắt đầu instance sub khi stage 1 hoàn thành
        start_stage7 <= 1;
    else if (done_X3_J)  // Tắt khi instance sub hoàn thành
        start_stage7 <= 0;
end

// R_SQ + G - 2V
 modular_subtractor sub71(
	.i_start(start_stage7),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.A(R_SQ_ADD_G),
	.B(twoV),
	.p(p),
	.result(X3_J),
	.done(done_X3_J)
);
  assign done_stage7 = done_X3_J;
//-----------------------------------------------//
// Stage 8
//-----------------------------------------------//
 logic start_stage8;
 logic done_stage8;
 logic done_V_SUB_X3_J ;
 logic [255:0] V_SUB_X3_J;
 //assign start_stage8 = done_stage7;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
        start_stage8 <= 0;
    else if (done_stage7)  // Bắt đầu instance sub khi stage 1 hoàn thành
        start_stage8 <= 1;
    else if (done_V_SUB_X3_J)  // Tắt khi instance sub hoàn thành
        start_stage8 <= 0;
end

// R_SQ + G - 2V
 modular_subtractor sub80(
	.i_start(start_stage8),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.A(V),
	.B(X3_J),
	.p(p),
	.result(V_SUB_X3_J),
	.done(done_V_SUB_X3_J)
);
  assign done_stage8= done_V_SUB_X3_J;

//-----------------------------------------------//
// Stage 9
//-----------------------------------------------//
 logic start_stage9;
// logic done_stage9;
 //logic done_Y3_J ;
 logic [255:0] Y3_J;
 //assign start_stage9 = done_stage8;
 logic start_pulse_stage9, start_d_stage9;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        start_d_stage9   <= 1'b0;
        start_pulse_stage9 <= 1'b0;
    end else begin
        start_d_stage9   <= done_stage8;                   // Lưu giá trị trước của i_start
        start_pulse_stage9 <= done_stage8 & ~start_d_stage9;      // Chỉ bật khi i_start chuyển từ 0 -> 1
    end
end
assign start_stage9 = start_pulse_stage9;


// R_SQ + G - 2V
  modular_multiplication mult90 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage9),
        .a(R),
        .b(V_SUB_X3_J),
        .m(p),
        .p(Y3_J),
        .ready(done_Y3_J)
    );
  assign done_stage9= done_Y3_J;
 
 //-----------------------------------------------//
 // Stage 10 : Stage đổi từ Jacobe sang Affine
 //-----------------------------------------------//
    logic start_stage10;
    logic done_stage10;
    logic [255:0]   Z3_J_SQ;
    logic done_Z3_J_SQ;
    logic start_pulse_stage10, start_d_stage10;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        start_d_stage10   <= 1'b0;
        start_pulse_stage10 <= 1'b0;
    end else begin
        start_d_stage10   <= done_stage9;                   // Lưu giá trị trước của i_start
        start_pulse_stage10 <= done_stage9 & ~start_d_stage10;      // Chỉ bật khi i_start chuyển từ 0 -> 1
    end
end
assign start_stage10 = start_pulse_stage10;


// Z3_J^2 
  modular_multiplication mult100 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage10),
        .a(Z3_J),
        .b(Z3_J),
        .m(p),
        .p(Z3_J_SQ),
        .ready(done_Z3_J_SQ)
    );
  assign done_stage10= done_Z3_J_SQ;
  //-----------------------------------------------//
    // Stage 11 : X3_J*1/Z3_J_SQ, Z3_J_CUBE
    //-----------------------------------------------//
    logic start_stage11;
    logic done_stage11;
    logic [255:0]  Z3_J_cube;
    logic done_Z3_J_cube;
    logic  done_X3;

logic start_pulse_stage11, start_d_stage11;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        start_d_stage11   <= 1'b0;
        start_pulse_stage11 <= 1'b0;
    end else begin
        start_d_stage11   <= done_stage10;                   // Lưu giá trị trước của i_start
        start_pulse_stage11 <= done_stage10 & ~start_d_stage11;      // Chỉ bật khi i_start chuyển từ 0 -> 1
    end
end
assign start_stage11 = start_pulse_stage11;
// Z3_J^3 
  modular_multiplication mult110 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage11),
        .a(Z3_J_SQ),
        .b(Z3_J),
        .m(p),
        .p(Z3_J_cube),
        .ready(done_Z3_J_cube)
    );

// X3_J*1/Z3_J_SQ 
    modular_inversion inver111 (
            .clk(i_clk),
            .rst_n(i_rst_n),
            .start(start_stage11),
            .a(Z3_J_SQ),
            .b(X3_J),
            .m(p),
            .c(X3),
            .ready(done_X3)
        );
        
always_ff @(posedge done_Z3_J_cube or negedge i_rst_n or posedge i_clk) begin
        if (!i_rst_n) begin
            done_stage11 <= 1'b0; 
        end else if (done_X3) begin
            done_stage11 <= 1'b1; 
        end
    end
    


//  assign done_stage11= done_X3 & done_Z3_J_cube;

//-----------------------------------------------//
// Stage 12         
//-----------------------------------------------//
    logic start_stage12;
    logic done_stage12;
    logic   done_Y3;
    logic start_pulse_stage12, start_d_stage12;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        start_d_stage12   <= 1'b0;
        start_pulse_stage12 <= 1'b0;
    end else begin
        start_d_stage12   <= done_stage11;                   // Lưu giá trị trước của i_start
        start_pulse_stage12 <= done_stage11 & ~start_d_stage12;      // Chỉ bật khi i_start chuyển từ 0 -> 1
    end
end
assign start_stage12 = start_pulse_stage12;
// y3  
    modular_inversion inver120 (
            .clk(i_clk),
            .rst_n(i_rst_n),
            .start(start_stage12),
            .a(Z3_J_cube),
            .b(Y3_J),
            .m(p),
            .c(Y3),
            .ready(done_Y3)
        );

  assign done_stage12= done_Y3;


  // Output
 assign o_done = done_stage12;
endmodule 

  
  
