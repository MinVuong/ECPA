module modular_addition(
    input logic i_start,
    input logic i_clk,
    input logic i_rst_n,
    input logic [255:0] A, B, p,
    output reg [255:0] result,
    output logic done
);

// Wire declarations
wire cout_1, cout_2, sel_R;
wire BKA1_done;
wire [255:0] BKA1_result;
wire BKA2_start, BKA2_done;
wire [255:0] BKA2_result;
wire [255:0] p_2s;
reg [255:0] i_result;
reg done_reg;

// BKA1: A + B
BK256 BKA1(
    .start(i_start),
    .clk(i_clk),
    .rst_n(i_rst_n), 
    .A(A),
    .B(B),
    .Ci(1'b0), // Ci = 0 because this is an adder 
    .S(BKA1_result),
    .Co(cout_1),
    .done(BKA1_done)
);

// BKA2: (A + B) - p
assign p_2s = ~p + 256'b1;
BK256 BKA2(
    .start(BKA1_done),
    .clk(i_clk),
    .rst_n(i_rst_n), 
    .A(BKA1_result),
    .B(p_2s), // p 2's complement
    .Ci(1'b0), // Ci = 0 because this is a subtractor 
    .S(BKA2_result),
    .Co(cout_2),
    .done(BKA2_done)
);

// 2:1 Mux to choose between s_m and s_m - p
assign sel_R = cout_2 | cout_1;
always_comb begin
    if (sel_R)
        i_result = BKA2_result;
    else
        i_result = BKA1_result;
end

// Register for result
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) 
        result <= 256'b0;
    else if (BKA2_done)
        result <= i_result;
end 

// Done signal, only high for 1 clock cycle
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
        done_reg <= 1'b0;
    else if (BKA2_done)
        done_reg <= 1'b1;
    else 
        done_reg <= 1'b0;
end

assign done = done_reg;

endmodule
