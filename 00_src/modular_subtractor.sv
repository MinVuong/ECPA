module modular_subtractor(
	input logic i_start,
	input logic i_clk,
	input logic i_rst_n,
	input logic [255:0] A,B,p,
	output reg [255:0] result,
	output logic done
);


////////--------DATAPATH--------/////////
//-------datapath variables--------//
//----Define temporary values-------//
wire cout_1, sel_R, cout_2;
//------BKA1 related--------//
wire BKA1_done;
wire [255:0] BKA1_result;
//------BKA2 related--------//
wire BKA2_start, BKA2_done;
wire [255:0] BKA2_result;
wire [255:0] B_2s;
assign B_2s = ~B+1'b1;
reg done_reg;
//------ 2-1 mux result related--------//
reg [255:0] i_result;
//-----Define BKA1 S = A+B -------Ci=0 because this is an adder//
BK256 BKA1(
	.start(i_start),
	.clk(i_clk),
	.rst_n(i_rst_n), 
   .A(A),
	.B(B_2s),
	.Ci(1'b0), // Ci = 0 because this is an adder 
	.S(BKA1_result),
	.Co(cout_1),
	.done(BKA1_done)
	);
//------Define BKA2 s_m = A+B-p-------//
BK256 BKA2(
	.start(BKA1_done),
	.clk(i_clk),
	.rst_n(i_rst_n), 
   	.A(BKA1_result),
	.B(p), 
	.Ci(1'b0), // Ci = 1 because this is an subtractor 
	.S(BKA2_result),
	.Co(cout_2),
	.done(BKA2_done)
	);
//-----Define Mux 2-1 to choose between s_m and s_m - p-------//
assign sel_R = cout_1;
/*
	begin
		if (BKA1_result <=p) begin
			sel_R = 1'b1;
		end else begin
			sel_R = cout_1;
		end
	end
	*/
//assign sel_R = (BKA1_result <= p) ? 1'b1 : cout_1;
always_comb 
	begin 
		if (sel_R)
			i_result = BKA1_result;
		else
			i_result = BKA2_result;
	end
always_ff @(posedge i_clk or negedge i_rst_n) 
begin 
	if (!i_rst_n) 
		result <= 256'b0;
	else if (BKA2_done)
		result <= i_result;
	else 
		result <= result;
end 
always @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) 
		done_reg <=1'b0;
		else if (BKA2_done) 
				done_reg <=1'b1;
				
		else done_reg <=1'b0;
	end

assign done = done_reg;
endmodule 