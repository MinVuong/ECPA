module ecpd (
  input  logic                i_clk,
  input  logic                i_rst_n,   // Active-low reset
  input  logic                i_start,   // Start signal for ECPD
  input  logic [255 : 0]  X1,
  input  logic [255 : 0]  Y1,
  input  logic [255 : 0]  Z1,
  input  logic [255 : 0]  p,     // Prime modulus p
  output logic [255 : 0]  X3,
  output logic [255 : 0]  Y3,
  output logic [255 : 0]  Z3,
  output logic                o_done     // Goes high when ECPD completes
);

  // --------------------------------------------------------
  // 1) Registers (logic) for inputs, intermediates, outputs
  // --------------------------------------------------------
/*  logic [255 : 0]  X1;
  logic [255 : 0]  Y1;
  logic [255 : 0]  Z1;
  logic [255 : 0]  p;    // Prime modulus p
  logic [255 : 0]  X3;
  logic [255 : 0]  Y3;
  logic [255 : 0]  Z3; */
// --------------------------------------------------------
// Stage 1 
//---------------------------------------------------------
  logic              stage1_start;
  logic              done_stage1;
  logic 					done_X1_2, done_4X1, done_Y1_2, done_Y1Z1;
  logic [255:0]		r_X1_2, r_Y1_2, r_4X1, r_Y1Z1;
//X1^2
assign stage1_start = i_start;
mont_final mult10(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (stage1_start),
    .A     (X1),
    .B     (X1),
    .P     (p),
    .M     (r_X1_2),
    .done  (done_X1_2)
  );
//4*X1
mont_final mult11(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (stage1_start),
    .A     (256'h4),
    .B     (X1),
    .P     (p),
    .M     (r_4X1),
    .done  (done_4X1)
  );
//Y1^2
mont_final mult12(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (stage1_start),
    .A     (Y1),
    .B     (Y1),
    .P     (p),
    .M     (r_Y1_2),
    .done  (done_Y1_2)
	);
//Y1Z1
mont_final mult13(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (stage1_start),
    .A     (Y1),
    .B     (Z1),
    .P     (p),
    .M     (r_Y1Z1),
    .done  (done_Y1Z1)
	);
assign done_stage1 = done_X1_2&done_4X1&done_Y1_2&done_Y1Z1;
// --------------------------------------------------------
// Stage 2 
//---------------------------------------------------------
  logic              stage2_start;
  logic              done_stage2;
  logic [255:0]		M, S,T, r_Y1_4;
  logic 					done_M, done_S, done_T, done_Z3 ;
  assign stage2_start = done_stage1;
//3X1^2
mont_final mult20(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (stage2_start),
    .A     (256'h3),
    .B     (r_X1_2),
    .P     (p),
    .M     (M),
    .done  (done_3X1_2)
  );
//4*X1*Y1^2 = S
mont_final  mult21(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (stage2_start),
    .A     (r_4X1),
    .B     (r_Y1_2),
    .P     (p),
    .M     (S),
    .done  (done_S)
  );
//Y1^4
mont_final mult22(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (stage2_start),
    .A     (r_Y1_2),
    .B     (r_Y1_2),
    .P     (p),
    .M     (T),
    .done  (done_T)
	);
//2Y1Z1
mont_final mult23(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (stage2_start),
    .A     (256'h2),
    .B     (r_Y1Z1),
    .P     (p),
    .M     (Z3),
    .done  (done_Z3)
	);
assign done_stage2 = done_M&done_S&done_T&done_Z3;
// --------------------------------------------------------
// Stage 3 
//---------------------------------------------------------
  logic              stage3_start;
  logic              done_stage3;
  logic [255:0]		M_2, r_2S, r_8T;
  logic 					done_M_2, done_2S, done_8T;
  assign stage3_start = done_stage2;
//M^2
mont_final mult30(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (stage3_start),
    .A     (M),
    .B     (M),
    .P     (p),
    .M     (M_2),
    .done  (done_M_2)
  );
//2S
mont_final  mult31(
    .clk   (i_clk),
    .rst_n (i_rst_n), 
    .start (stage3_start),
    .A     (S),
    .B     (256'h2),
    .P     (p),
    .M     (r_2S),
    .done  (done_2S)
  );
//8Y1^4
mont_final mult32(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (stage3_start),
    .A     (T),
    .B     (256'h8),
    .P     (p),
    .M     (r_8T),
    .done  (done_8T)
	);
assign done_stage3 = done_M_2&done_2S&done_8T;
// --------------------------------------------------------
// Stage 4 
//---------------------------------------------------------
  logic              stage4_start;
  logic              done_stage4;
  logic 					done_X3;
  assign stage4_start = done_stage3;
//X3 = M^2 - 2S 
modular_subtractor sub40(
	.i_start(stage4_start),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.A(M_2),
	.B(r_2S),
	.p(p),
	.result(X3),
	.done(done_X3)
);
assign done_stage4 = done_X3;
// --------------------------------------------------------
// Stage 5 
//---------------------------------------------------------
  logic              stage5_start;
  logic              done_stage5;
  logic [255:0]		r_S_sub_X3;
  logic 					done_S_sub_X3;
  assign stage5_start = done_stage4;
//M^2 - 2S
modular_subtractor sub50(
	.i_start(stage5_start),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.A(S),
	.B(X3),
	.p(p),
	.result(r_S_sub_X3),
	.done(done_S_sub_X3)
);
assign done_stage5 = done_S_sub_X3;
// --------------------------------------------------------
// Stage 6 
//---------------------------------------------------------
  logic              stage6_start;
  logic              done_stage6;
  logic [255:0]		M_and_S_sub_X3;
  logic 					done_M_and_S_sub_X3;
  assign stage6_start = done_stage5;
//M*(S-X3)
mont_final mult60(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (stage2_start),
    .A     (M),
    .B     (r_S_sub_X3),
    .P     (p),
    .M     (M_and_S_sub_X3),
    .done  (done_M_and_S_sub_X3)
  );
assign done_stage6 = done_M_and_S_sub_X3;
// --------------------------------------------------------
// Stage 7 
//---------------------------------------------------------
  logic              stage7_start;
  logic              done_stage7;
  logic 					done_Y3;
  assign stage7_start = done_stage6;
//M*(S-X3)
mont_final mult70(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (stage2_start),
    .A     (M_and_S_sub_X3),
    .B     (r_8T),
    .P     (p),
    .M     (Y3),
    .done  (done_Y3)
  );
assign done_stage7 = done_Y3;
//------//
assign o_done = done_stage7;
endmodule 