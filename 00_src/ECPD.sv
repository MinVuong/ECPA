module ECPD (
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
//assign stage1_start = i_start;
logic start_pulse1, i_start_d1;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        i_start_d1   <= 1'b0;
        start_pulse1 <= 1'b0;
    end else begin
        i_start_d1   <= i_start;                   
        start_pulse1 <= i_start & ~i_start_d1;      
    end
end
assign stage1_start = start_pulse1;
//X1^2
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
logic start_pulse2, i_start_d2;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        i_start_d2  <= 1'b0;
        start_pulse2 <= 1'b0;
    end else begin
        i_start_d2   <= done_stage1;                  
        start_pulse2 <= done_stage1 & ~i_start_d2;      
    end
end
assign stage2_start = start_pulse2;

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
modular_multiplication  mult21(
    .clk   (i_clk),
    .rst_n (i_rst_n),
    .start (stage2_start),
    .a     (r_4X1),
    .b     (r_Y1_2),
    .m     (p),
    .p     (S),
    .ready  (done_S)
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
// assign stage3_start = done_stage2;

logic start_pulse3, i_start_d3;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        i_start_d3  <= 1'b0;
        start_pulse3 <= 1'b0;
    end else begin
        i_start_d3   <= done_stage2;                   
        start_pulse3 <= done_stage2 & ~i_start_d3;      
    end
end
assign stage3_start = start_pulse3;

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

   modular_multiplication mult32 (
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
  logic 	     done_X3;
assign start_stage4 = done_stage3;
always_ff @(posedge i_clk or posedge i_rst_n) begin
        if (!i_rst_n) begin
            stage4_start <= 1'b0; 
        end else if (start_stage4) begin
            stage4_start <= 1'b1; 
        end
    end

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
  logic [255:0]	     r_S_sub_X3;
  logic 	     done_S_sub_X3;
assign start_stage5 = done_stage4;
always_ff @(posedge i_clk or posedge i_rst_n) begin
        if (!i_rst_n) begin
            stage5_start <= 1'b0; // Reset the stage5_start signal
        end else if (start_stage5) begin
            stage5_start <= 1'b1; // Set stage5_start to 1 when start_stage5 is high
        end
    end
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
  logic 		done_M_and_S_sub_X3;
logic start_pulse6, i_start_d6;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        i_start_d6  <= 1'b0;
        start_pulse6 <= 1'b0;
    end else begin
        i_start_d6   <= done_stage5;                   
        start_pulse6 <= done_stage5 & ~i_start_d6;      
    end
end
assign stage6_start = start_pulse6;

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
  logic 	     done_Y3;

assign start_stage7 = done_stage6;
always_ff @(posedge i_clk or posedge i_rst_n) begin
        if (!i_rst_n) begin
            stage7_start <= 1'b0; 
        end else if (start_stage7) begin
            stage7_start <= 1'b1; 
        end
    end

//M*(S-X3)
modular_subtractor sub70(
    .i_clk   (i_clk),
    .i_rst_n (i_rst_n),
    .i_start (stage7_start),
    .A     (M_and_S_sub_X3),
    .B     (r_8T),
    .p     (p),
    .result (Y3),
    .done (done_Y3)
  );
  
assign done_stage7 = done_Y3;
//------//
assign o_done = done_stage7;
endmodule 
