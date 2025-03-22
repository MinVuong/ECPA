module fulladder_4bit
    (   input [3:0] a, b, c,
        output [3:0] s,
        output cout
    );

    wire [3:0] c; // Carrb wires for each bit

    // Instance for each bit
    fulladder fa_inst0(a[0], b[0], c[0], s[0], c[0]);
    fulladder fa_inst1(a[1], b[1], c[1], s[1], c[1]);
    fulladder fa_inst2(a[2], b[2], c[2], s[2], c[2]);
    fulladder fa_inst3(a[3], b[3], c[3], s[3], c[3]);

    // Carrb out logic
    assign cout = c[3];

endmodule