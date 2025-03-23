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

  modular_multiplication mult10 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(stage1_start),
        .a(X1),
        .b(X1),
        .m(p),
        .p(r_X1_2),
        .ready(done_X1_2)
    );
//4*X1

   modular_multiplication mult11 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(stage1_start),
        .a(256'h4),
        .b(X1),
        .m(p),
        .p(r_4X1),
        .ready(done_4X1)
    );
//Y1^2

   modular_multiplication mult12 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(stage1_start),
        .a(Y1),
        .b(Y1),
        .m(p),
        .p(r_Y1_2),
        .ready(done_Y1_2)
    );
//Y1Z1
   modular_multiplication mult13 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(stage1_start),
        .a(Y1),
        .b(Z1),
        .m(p),
        .p(r_Y1Z1),
        .ready(done_Y1Z1)
    );
assign done_stage1 = done_X1_2&done_4X1&done_Y1_2&done_Y1Z1;
// --------------------------------------------------------
// Stage 2 
//---------------------------------------------------------
  logic              stage2_start;
  logic              done_stage2;
  logic [255:0]		M, S,T;
  logic 					done_M, done_S, done_T, done_Z3 ;
  assign stage2_start = done_stage1;
//3X1^2
   modular_multiplication mult20 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(stage2_start),
        .a(256'h3),
        .b(r_X1_2),
        .m(p),
        .p(M),
        .ready(done_M)
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
   modular_multiplication mult21 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(stage2_start),
        .a(r_4X1),
        .b(r_Y1_2),
        .m(p),
        .p(S),
        .ready(done_S)
    );
//Y1^4

   modular_multiplication mult22 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(stage2_start),
        .a(r_Y1_2),
        .b(r_Y1_2),
        .m(p),
        .p(T),
        .ready(done_T)
    );
//2Y1Z1

   modular_multiplication mult23 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(stage2_start),
        .a(256'h2),
        .b(r_Y1Z1),
        .m(p),
        .p(Z3),
        .ready(done_Z3)
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

   modular_multiplication mult30 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(stage3_start),
        .a(M),
        .b(M),
        .m(p),
        .p(M_2),
        .ready(done_M_2)
    );
//2S

   modular_multiplication mult31 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(stage3_start),
        .a(S),
        .b(256'h2),
        .m(p),
        .p(r_2S),
        .ready(done_2S)
    );
//8Y1^4

   modular_multiplication mult30 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(stage3_start),
        .a(T),
        .b(256'h8),
        .m(p),
        .p(r_8T),
        .ready(done_8T)
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

   modular_multiplication mult60 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(stage6_start),
        .a(M),
        .b(r_S_sub_X3),
        .m(p),
        .p(M_and_S_sub_X3),
        .ready(done_M_and_S_sub_X3)
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
    .start (stage7_start),
    .A     (M_and_S_sub_X3),
    .B     (r_8T),
    .P     (p),
    .M     (Y3),
    .done  (done_Y3)
  );
   modular_multiplication mult70 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(stage7_start),
        .a(M_and_S_sub_X3),
        .b(r_8T),
        .m(p),
        .p(Y3),
        .ready(done_Y3)
    );
  
assign done_stage7 = done_Y3;
//------//
assign o_done = done_stage7;
endmodule 
