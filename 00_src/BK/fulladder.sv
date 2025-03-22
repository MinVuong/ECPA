module fulladder(
	input logic a,
	input logic b,
	input logic c,
	output logic s,
	output logic cout
	);

	assign s = a ^ b ^ c;
	assign cout = (a & b) | (a & c) | (b & c);

endmodule
