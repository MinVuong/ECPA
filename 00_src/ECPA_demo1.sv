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
 mont_final mult10(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage1),
    .A     (Z1),
    .B     (Z2),
    .P     (p),
    .M     (Z1_Z2),
    .done  (done_Z1_Z2)
  );
// Z1_SQ
mont_final mult11(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage1),
    .A     (Z1),
    .B     (Z1),
    .P     (p),
    .M     (Z1_SQ),
    .done  (done_Z1_SQ)
  );
//Z2_SQ
mont_final mult12(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage1),
    .A     (Z2),
    .B     (Z2),
    .P     (p),
    .M     (Z2_SQ),
    .done  (done_Z2_SQ)
	);
  assign done_stage1 = done_Z1_SQ&done_Z2_SQ&done_Z1_Z2;

//----------------------------------------//
// Stage 2
//----------------------------------------//
logic start_stage2;
 logic done_stage2;
 logic done_Z1_cube, done_U1, done_U2 ;
 logic [255:0] Z1_cube, Z2_cube, U1, U2;
 assign start_stage2 = done_stage1;

//Z1_cube
 mont_final mult20(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage2),
    .A     (Z1_SQ),
    .B     (Z1),
    .P     (p),
    .M     (Z1_cube),
    .done  (done_Z1_cube)
  );
// Z2_cube
mont_final mult21(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage2),
    .A     (Z2_SQ),
    .B     (Z2),
    .P     (p),
    .M     (Z2_cube),
    .done  (done_Z2_cube)
  );
//U1
mont_final mult22(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage2),
    .A     (X1),
    .B     (Z2_SQ),
    .P     (p),
    .M     (U1),
    .done  (done_U1)
	);
mont_final mult23(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage2),
    .A     (X2),
    .B     (Z1_SQ),
    .P     (p),
    .M     (U2),
    .done  (done_U2)
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
 mont_final mult30(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage3),
    .A     (Y1),
    .B     (Z2_cube),
    .P     (p),
    .M     (S1),
    .done  (done_S1)
  );
// S2= Y2*Z1_cube 
mont_final mult31(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage3),
    .A     (Y2),
    .B     (Z1_cube),
    .P     (p),
    .M     (S2),
    .done  (done_S2)
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
 mont_final mult41(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage4),
    .A     (Z1_Z2),
    .B     (H),
    .P     (p),
    .M     (Z3),
    .done  (done_Z3)
  );
// H_SQ 
mont_final mult42(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage4),
    .A     (H),
    .B     (H),
    .P     (p),
    .M     (H_SQ),
    .done  (done_H_SQ)
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
 mont_final mult50(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage5),
    .A     (U1),
    .B     (H_SQ),
    .P     (p),
    .M     (V),
    .done  (done_V)
  );

// H_cube
 mont_final mult51(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage5),
    .A     (H_SQ),
    .B     (H),
    .P     (p),
    .M     (H_cube),
    .done  (done_H_cube)
  );
// R_SQ
mont_final mult52(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage5),
    .A     (R),
    .B     (R),
    .P     (p),
    .M     (R_SQ),
    .done  (done_R_SQ)
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
 mont_final mult60(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage6),
    .A     (256'h2),
    .B     (V),
    .P     (p),
    .M     (twoV),
    .done  (done_twoV)
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
 mont_final mult90(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (start_stage9),
    .A     (R),
    .B     (V_SUB_X3),
    .P     (p),
    .M     (Y3),
    .done  (o_done)
  );
  /*assign done_stage9= done_Y3;
  logic done_stage9_reg;
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
 // assign o_done = done_stage9_reg;
endmodule 

  
  
