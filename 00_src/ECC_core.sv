
// 
module ECC_core(
	input logic start,
	input logic i_clk,
	input logic i_rst_n,
	input logic [255:0] a,
	input logic [255:0] b,
	input logic [255:0] prime,
	input logic [255:0] n,
	input logic [2:0] ecc_sel,
	output logic [255:0] alu_result,
	output logic done
	);

//chon p va n
logic [255:0] p_or_n; 
always_comb begin
	if (ecc_sel[0]) begin
	p_or_n =n;
	end else begin
	p_or_n = prime;
	end
end	

//wire
logic start_add, start_sub, start_mult, start_inv;
logic [255:0] result_add, result_sub, result_mult, result_inv;
logic done_add, done_sub, done_mult, done_inv;
logic busy_inv, ready0_inv;
logic rst_modular;
logic reset; // reset by state_machine
assign rst_modular = ~i_rst_n || reset; //rst_modular = i_rst_n&reset;
//localparamSS
localparam CLEAR = 1'b0;
localparam SET = 1'b1;
logic start_mult_delay;



//module addition
modular_addition modular_addition(
	.i_start(start_add),
	.i_clk(i_clk),
	.i_rst_n(rst_modular),
	.p(p_or_n), 
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
	.p(p_or_n),
	.result(result_sub),
	.done(done_sub)
);
//modular multiplication

modular_multiplication modular_multiplication(
	.clk(i_clk), 
	.rst_n(rst_modular), 
	.start(start_mult), 
	.a(a), 
	.b(b), 
	.m(p_or_n), 
	.p(result_mult), 
	.ready(done_mult)
);


//modular inversion c=m*a^-1
modular_inversion modular_inversion(
	.clk(i_clk), 
	.rst_n(rst_modular), 
	.start(start_inv), 
	.b(a), 
	.a(b), 
	.m(p_or_n), 
	.c(result_inv), 
	.ready(done_inv) 

);
// mux 4->1 
always_comb begin
    if (done) begin
        case (ecc_sel[2:1])
            2'b00: alu_result = result_add; 
            2'b01: alu_result = result_sub;
            2'b10: alu_result = result_mult;
            2'b11: alu_result = result_inv;
            default: alu_result = 256'b0;
        endcase
    end else begin
        alu_result = 256'b0; // Hoặc giá trị mặc định khác nếu done = 0
    end
end

enum logic[3:0] {Idle = 4'b0000, Add = 4'b0001, Sub = 4'b0010, Mult = 4'b0011, Inversion = 4'b0100,  Complete = 4'b0111, Complete_wait = 4'b1000 } state = Idle;



//-----State Machine------//
always @(posedge i_clk)
	begin
		if (!i_rst_n)
			state <= Idle;
		else begin
				case (state)
				Idle: begin 
					if (start) begin
						case (ecc_sel[2:1])
							`ALU_ADD: state <= Add;
							`ALU_SUB: state <= Sub;
							`ALU_MULT: state <= Mult;
							`ALU_INV: state <= Inversion;
					
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
					if (done_inv)
						state <= Complete;	
					else state <= Inversion;
				
				Complete:
						state <= Complete_wait;
				Complete_wait: begin 
					if (!start) state <= Idle; // Chờ start được gỡ
					else state <= Complete_wait;
					end 

				default:
					state <= Idle;
				endcase
			end
	end
	// Tạo xung cho start_mult
logic start_mult_pulse, start_mult_d;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        start_mult_d <= 1'b0;
        start_mult_pulse <= 1'b0;
    end else begin
        start_mult_d <= (state == Mult); // Lưu trạng thái trước đó của Mult
        start_mult_pulse <= (state == Mult) & ~start_mult_d; // Xung chỉ bật khi vào trạng thái Mult
    end
end

logic start_inv_pulse, start_inv_d;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        start_inv_d <= 1'b0;
        start_inv_pulse <= 1'b0;
    end else begin
        start_inv_d <= (state == Inversion); // Lưu trạng thái trước đó của Mult
        start_inv_pulse <= (state == Inversion) & ~start_inv_d; // Xung chỉ bật khi vào trạng thái Mult
    end
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
				reset = CLEAR; //BD SET, chỉnh clear để có reset ở stage 1
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
	start_mult = start_mult_pulse; // Sử dụng tín hiệu bị trễ 1 clock
	start_inv = CLEAR;
	reset = SET;
	done = CLEAR;
end 

			Inversion : begin
				start_add = CLEAR;
				start_sub = CLEAR;
				start_mult = CLEAR;
				start_inv = start_inv_pulse; // Sử dụng tín hiệu bị trễ 1 clock
				reset = SET;
				done = CLEAR;
			end
		
			Complete : begin
				start_add = CLEAR;
				start_sub = CLEAR;
				start_mult = CLEAR;
				start_inv = CLEAR;
				reset = SET;
				done = CLEAR;
				end
			Complete_wait : begin
				start_add = CLEAR;
				start_sub = CLEAR;
				start_mult = CLEAR;
				start_inv = CLEAR;
				reset = SET; //BD SET, chỉnh clear để có reset ở stage 1
				done = SET;
			end
				
		endcase
end

endmodule : ECC_core
