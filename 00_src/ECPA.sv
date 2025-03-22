module ECPA (
    input         i_clk,
    input         i_rst_n,
    input         i_start,
    input  [255:0] p,
    // P = (X1, Y1, Z1)
    input  [255:0] X1,
    input  [255:0] Y1,
    input  [255:0] Z1,
    // Q = (X2, Y2, Z2)
    input  [255:0] X2,
    input  [255:0] Y2,
    input  [255:0] Z2,
    // R = (X3, Y3, Z3)
    output logic [255:0] X3,
    output logic [255:0] Y3,
    output logic [255:0] Z3,
    output logic         o_done
);

//-----------------------------------------------//
// Stage 1
//-----------------------------------------------//
 logic start_stage1;
 logic done_stage1;
 logic done_Z1_Z2, done_Z1_SQ, done_Z2_SQ ;
 logic [255:0] Z1_Z2, Z1_SQ, Z2_SQ;
 assign start_stage1 = i_start;


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
        .ready(done_Z1_SQ)
    );
  assign done_stage1 = done_Z1_SQ&done_Z2_SQ&done_Z1_Z2;

//----------------------------------------//
// Stage 2
//----------------------------------------//
logic start_stage2;
 logic done_stage2;
 logic done_Z1_cube, done_U1, done_U2, done_Z2_cube ;
 logic [255:0] Z1_cube, Z2_cube, U1, U2;
 assign start_stage2 = done_stage1;

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
 assign start_stage3 = done_stage2;

//S1 = Y1*Z2_cube
 modular_multiplication mult30 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage3),
        .a(Y1),
        .b(Z2_CUBE),
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
        .b(Z1_CUBE),
        .m(p),
        .p(S2),
        .ready(done_S2)
    );
//h = U1-U22
modular_subtractor sub32(
	.i_start(start_stage3),
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
 logic done_R, done_Z3, done_H_SQ ;
 logic [255:0] R, H_SQ;
 assign start_stage4 = done_stage3;

//R=S1-S2
modular_subtractor sub40(
	.i_start(start_stage4),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.A(S1),
	.B(S2),
	.p(p),
	.result(R),
	.done(done_R)
);

// Z3 = Z1Z2*H
 modular_multiplication mult41 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage4),
        .a(Z1_Z2),
        .b(H),
        .m(p),
        .p(Z3),
        .ready(done_Z3)
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

  assign done_stage4 = done_R&done_Z3&done_H_SQ;

//-----------------------------------------------//
// Stage 5
//-----------------------------------------------//
 logic start_stage5;
 logic done_stage5;
 logic done_V, done_H_cube, done_R_SQ ;
 logic [255:0] V,H_cube, R_SQ;
 assign start_stage5 = done_stage4;

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
 assign start_stage6 = done_stage5;

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
	.i_start(start_stage6),
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
 logic done_X3 ;
 //logic [255:0] X3;
 assign start_stage7 = done_stage6;


// R_SQ + G - 2V
 modular_subtractor sub71(
	.i_start(start_stage7),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.A(R_SQ_ADD_G),
	.B(twoV),
	.p(p),
	.result(X3),
	.done(done_X3)
);
  assign done_stage7 = done_X3;
//-----------------------------------------------//
// Stage 8
//-----------------------------------------------//
 logic start_stage8;
 logic done_stage8;
 logic done_V_SUB_X3 ;
 logic [255:0] V_SUB_X3;
 assign start_stage8 = done_stage7;


// R_SQ + G - 2V
 modular_subtractor sub80(
	.i_start(start_stage8),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.A(V),
	.B(X3),
	.p(p),
	.result(V_SUB_X3),
	.done(done_V_SUB_X3)
);
  assign done_stage8= done_V_SUB_X3;

//-----------------------------------------------//
// Stage 9
//-----------------------------------------------//
 logic start_stage9;
// logic done_stage9;
 //logic done_Y3 ;
 //logic [255:0] Y3;
 assign start_stage9 = done_stage8;


// R_SQ + G - 2V
  modular_multiplication mult90 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_stage9),
        .a(R),
        .b(V_SUB_X3),
        .m(p),
        .p(Y3),
        .ready(done_Y3)
    );
  assign done_stage9= done_Y3;
  /*logic done_stage9_reg;
  always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n || ~i_start) begin 
      done_stage9_reg <=0;
      end
      else begin
        done_stage9_reg <= done_stage9;
        end
        end
*/

  // Output
 assign o_done = done_stage9;
endmodule 

  
  
