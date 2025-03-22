
module ECC_core(
	input logic start,
	input logic i_clk,
	input logic i_rst_n,
	input logic [255:0] a,
	input logic [255:0] b,
	input logic [255:0] prime,
	//input logic [255:0] constant,
	input logic [2:0] alu_sel,
	output logic [255:0] alu_result,
	output logic done
	);
//wire [255:0] a;
//wire [255:0] b;
//wire [255:0] constant;
//wire [255:0] prime;
//wire logic [2:0] alu_sel;
//assign a = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // Giá trị a
//assign b = 256'h0000000000000000000000000000000000000000000000000000000000000001; // Giá trị b
//assign prime = 256'h0000000000000000000000000000000000000000000000000000000000001111;
//assign constant = 256'h0000000000000000000000000000000000000000000000000000000000000002; // Giá trị constant
    // Gán giá trị cho alu_sel
//assign alu_sel = 3'b001; // Chọn phép toán cộng

//wire
logic start_add, start_sub, start_mult, start_inv;
logic [255:0] result_add, result_sub, result_mult, result_inv;
logic done_add, done_sub, done_mult, done_inv;
logic busy_inv, ready0_inv;
logic rst_modular;
logic reset; // reset by state_machine
assign rst_modular = i_rst_n&reset;
//logic [255:0] prime;
//localparam
localparam CLEAR = 1'b0;
localparam SET = 1'b1;
logic start_mult_delay;

//module addition
modular_addition modular_addition(
	.i_start(start_add),
	.i_clk(i_clk),
	.i_rst_n(rst_modular),
	.p(prime), 
	.A(a), 
	.B(b),
	.result(result_add),
	.done(done_add)
);
//modular subtractor
modular_subtractor modular_subtractor(
	.i_start(start_sub),
	.i_clk(i_clk),
	.i_rst_n(rst_modular),
	.A(a),
	.B(b),
	.p(prime),
	.result(result_sub),
	.done(done_sub)
);
//modular multiplier
mont_final modular_multiplier(
	.clk(i_clk),
	.rst_n(rst_modular),
	.start(start_mult),
	.A(a),
	.B(b),
	.P(prime),
	.M(result_mult),
	.done(done_mult)
);
//modular inversion c=m*a^-1
modular_inversion modular_inversion(
	.clk(i_clk), 
	.rst_n(rst_modular), 
	.start(start_inv), 
	.b(b), 
	.a(a), 
	.m(prime), 
	.c(result_inv), 
	.ready(done_inv), 
	.busy(busy_inv), 
	.ready0(ready0_inv)
);
// mux 4->1 
always_comb begin
    if (done) begin
        case (alu_sel)
            3'b001: alu_result = result_add; 
            3'b010: alu_result = result_sub;
            3'b011: alu_result = result_mult;
            3'b100: alu_result = result_inv;
            default: alu_result = 256'b0;
        endcase
    end else begin
        alu_result = 256'b0; // Hoặc giá trị mặc định khác nếu done = 0
    end
end

enum logic[2:0] {Idle = 3'b000, Add = 3'b001, Sub = 3'b010, Mult = 3'b011, Inversion = 3'b100, Inversion1 = 3'b101, Complete = 3'b111 } state = Idle;
//-----State Machine------//
always @(posedge i_clk)
	begin
		if (!i_rst_n)
			state <= Idle;
		else begin
				case (state)
				Idle: begin 
					if (start) begin
						case (alu_sel)
							`ALU_ADD: state <= Add;
							`ALU_SUB: state <= Sub;
							`ALU_MULT: state <= Mult;
							`ALU_INV: state <= Inversion;
							`ALU_NOP: state <= Complete;
						endcase
					end
					else
						state <= Idle;
				end
				Add: 
					if (done_add)
						state <= Complete;
					else 
						state <= Add;
				Sub: 
					if (done_sub)
						state <= Complete;
					else 
						state <= Sub;
				Mult: 
					if (done_mult)
						state <= Complete;
					else 
						state <= Mult;
				Inversion: 
						state <= Inversion1;
				Inversion1: 
					if (done_inv)
						state <= Complete;
					else 
						state <= Inversion1;
				Complete:
						state <= Idle;
				default:
					state <= Idle;
				endcase
			end
	end
	always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
        start_mult_delay <= 1'b0;
    else if (state == Mult) 
        start_mult_delay <= 1'b1; // Bật start_mult_delay sau 1 clock khi vào trạng thái Mult
    else 
        start_mult_delay <= 1'b0; // Reset khi không ở trạng thái Mult
end

//control unit

always_comb begin
		start_add = CLEAR;
		start_sub = CLEAR;
		start_mult = CLEAR;
		start_inv = CLEAR;
		reset = SET;
		done = CLEAR;
		case (state)
			Idle: begin
				start_add = CLEAR;
				start_sub = CLEAR;
				start_mult = CLEAR;
				start_inv = CLEAR;
				reset = CLEAR;
				done = CLEAR;
			end
			Add : begin
				start_add = SET;
				start_sub = CLEAR;
				start_mult = CLEAR;
				start_inv = CLEAR;
				reset = SET;
				done = CLEAR;
			end
			Sub : begin
				start_add = CLEAR;
				start_sub = SET;
				start_mult = CLEAR;
				start_inv = CLEAR;
				reset = SET;
				done = CLEAR;
			end
			Mult : begin
	start_add = CLEAR;
	start_sub = CLEAR;
	start_mult = start_mult_delay; // Sử dụng tín hiệu bị trễ 1 clock
	start_inv = CLEAR;
	reset = SET;
	done = CLEAR;
end 

			Inversion : begin
				start_add = CLEAR;
				start_sub = CLEAR;
				start_mult = CLEAR;
				start_inv = SET;
				reset = SET;
				done = CLEAR;
			end
			Inversion1 : begin
				start_add = CLEAR;
				start_sub = CLEAR;
				start_mult = CLEAR;
				start_inv = CLEAR;
				reset = SET;
				done = CLEAR;
			end
			Complete : begin
				start_add = CLEAR;
				start_sub = CLEAR;
				start_mult = CLEAR;
				start_inv = CLEAR;
				reset = SET;
				done = SET;
			end
		endcase
end

endmodule : ECC_core
