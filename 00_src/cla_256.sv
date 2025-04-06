module cla_256 (
    input  [255:0] a,
    input  [255:0] b,
    input          cin,
    output [255:0] sum,
    output         cout
);
    wire [7:0] P, G;
    wire [7:0] C;

    wire [255:0] s_block;
    assign C[0] = cin;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : block
            cla_32 cla_block (
                .a   (a[i*32 +: 32]),
                .b   (b[i*32 +: 32]),
                .cin (C[i]),
                .sum (sum[i*32 +: 32]),
                .cout(), // bỏ qua cout nội bộ
                .P   (P[i]),
                .G   (G[i])
            );
        end
    endgenerate

    // Generate carry cho các block tiếp theo
    generate
        for (i = 1; i < 8; i = i + 1) begin
            assign C[i] = G[i-1] | (P[i-1] & C[i-1]);
        end
    endgenerate

    assign cout = G[7] | (P[7] & C[7]);

endmodule
