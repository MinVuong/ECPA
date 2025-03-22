module csa_16 (
    input clk, rst_n,              // Clock and active-low reset
    input [15:0] x, y, z,          // 16-bit inputs
    output reg [16:0] s,           // 17-bit sum output (1 extra bit for carry out)
    output reg cout                // Final carry out
);

    reg [15:0] c1, s1, c2; // Intermediate registers for carry and sum

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s  <= 17'b0;
            cout <= 1'b0;
            c1 <= 16'b0;
            s1 <= 16'b0;
            c2 <= 16'b0;
        end else begin
            // First stage: Add each bit from x, y, z
            for (i = 0; i < 16; i = i + 1) begin
                {c1[i], s1[i]} = x[i] + y[i] + z[i];
            end
            
            // Second stage: Add sum and carry bits
            s[0] = s1[0]; // LSB remains unchanged
            {c2[1], s[1]} = s1[1] + c1[0];
            for (i = 2; i < 16; i = i + 1) begin
                {c2[i], s[i]} = s1[i] + c1[i-1] + c2[i-1];
            end
            {cout, s[16]} = c1[15] + c2[15]; // Final carry
        end
    end

endmodule
