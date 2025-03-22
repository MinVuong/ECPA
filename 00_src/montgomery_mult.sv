module montgomery_mult #(parameter WIDTH = 256) (
    input logic clk,
    input logic rst,
    input logic start,
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    input logic [WIDTH-1:0] m,
    input logic [WIDTH-1:0] m_inv,  // m_inv = -m^(-1) mod R
    output logic [WIDTH-1:0] result,
    output logic done
);

    logic [WIDTH-1:0] T, Q, temp;
    logic [WIDTH:0] S;
    logic [8:0] i;
    logic busy;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            T <= 0;
            Q <= 0;
            S <= 0;
            i <= 0;
            done <= 0;
            busy <= 0;
        end else if (start && !busy) begin
            T <= 0;
            Q <= 0;
            S <= 0;
            i <= 0;
            busy <= 1;
            done <= 0;
        end else if (busy) begin
            if (i < WIDTH) begin
                S = T[0] + (a[i] ? b : 0) + (T[0] * m);
                Q = S[0] * m_inv;
                temp = (S + Q * m) >> 1;
                T <= temp;
                i <= i + 1;
            end else begin
                if (T >= m)
                    T <= T - m;
                result <= T;
                done <= 1;
                busy <= 0;
            end
        end
    end

endmodule
