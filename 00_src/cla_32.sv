module cla_32 (
    input  [31:0] a,
    input  [31:0] b,
    input         cin,
    output [31:0] sum,
    output        cout,
    output        P,    // propagate toàn block
    output        G     // generate toàn block
);
    wire [31:0] g, p, c;

    assign g = a & b;
    assign p = a ^ b;

    assign c[0] = cin;
    genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin
            assign c[i] = g[i-1] | (p[i-1] & c[i-1]);
        end
    endgenerate

    assign sum = p ^ c;
    assign cout = c[31];

    assign P = &p;  // Propagate toàn block
    assign G = g[31] | (p[31] & g[30]) | (p[31] & p[30] & g[29]); // Có thể mở rộng cho chính xác hơn

endmodule
