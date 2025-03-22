module mont_exponent #(
    parameter W = 256
)(
    input clk,
    input rst_n,
    input start,
    input [W-1:0] e,    // Exponent in binary
    input [W-1:0] P,    // Modulus (N)
    input [W-1:0] M,    // Base (M)
    output reg [W-1:0] C, // Result: C = M^e mod N
    output reg done
);
    // Fixed value for R^2
    wire [W:0] R_2 = 257'b10000000000000000000000000000000000000000000000000000000000000000; // R^2 fixed to 1

    // Internal Registers
    reg [W-1:0] reg_C, reg_S, reg_A, reg_B;
    reg [8:0] i; // Index for exponent bits
    reg [2:0] state;
    reg start_mont3;

    wire done_mont1, done_mont2, done_mont3;
    wire [W-1:0] out_C_mont1, out_C_mont2, out_C_mont3;

    // Montgomery modules
    // First Montgomery: Montg(1, R^2, N)
    montgomery_257 mont1 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .A(256'h1),  // A = 1
        .B(R_2),     // B = R^2
        .P(P),
        .M(out_C_mont1),
        .done(done_mont1)
    );

    // Second Montgomery: Montg(M, R^2, N)
    montgomery_257 mont2 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .A(M),       // A = M
        .B(R_2),     // B = R^2
        .P(P),
        .M(out_C_mont2),
        .done(done_mont2)
    );

    // Third Montgomery for FSM computations
    montgomery mont3 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_mont3),
        .A(reg_A),
        .B(reg_B),
        .P(P),
        .M(out_C_mont3),
        .done(done_mont3)
    );

    // FSM States
    localparam IDLE = 3'b000,
               INIT = 3'b001,
               COMPUTE = 3'b010,
               FINALIZE = 3'b011;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            C <= 0;
            done <= 0;
            reg_C <= 0;
            reg_S <= 0;
            reg_A <= 0;
            reg_B <= 0;
            i <= 0;
            start_mont3 <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= INIT;
                        done <= 0;
                    end
                end

                INIT: begin
                    if (done_mont1 && done_mont2) begin
                        reg_C <= out_C_mont1; // C = Montg(1, R^2, N)
                        reg_S <= out_C_mont2; // S = Montg(M, R^2, N)
                        i <= 0;
                        state <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    if (i < W) begin
                        if (!start_mont3) begin
                            if (e[i]) begin
                                // Nếu e[i] = 1, tính C = Montg(C, S, N)
                                reg_A <= reg_C; // A = C
                                reg_B <= reg_S; // B = S
                                start_mont3 <= 1;
                            end else begin
                                // Nếu e[i] = 0, tính S = Montg(S, S, N)
                                reg_A <= reg_S; // A = S
                                reg_B <= reg_S; // B = S
                                start_mont3 <= 1;
                            end
                        end else if (done_mont3) begin
                            if (e[i]) begin
                                reg_C <= out_C_mont3; // C = Montg(C, S, N)
                                // Sau khi tính xong C, chuẩn bị tính S = Montg(S, S, N)
                                reg_A <= reg_S; // A = S
                                reg_B <= reg_S; // B = S
                                start_mont3 <= 1; // Khởi động tính toán tiếp
                            end else begin
                                reg_S <= out_C_mont3; // S = Montg(S, S, N)
                                i <= i + 1;           // Chuyển sang bit tiếp theo của e
                                start_mont3 <= 0;
                            end
                        end
                    end else begin
                        state <= FINALIZE;
                    end
                end


                FINALIZE: begin
                    if (!start_mont3) begin
                        // Compute C = Montg(C, 1, N)
                        reg_A <= reg_C;  // A = C
                        reg_B <= 256'h1; // B = 1
                        start_mont3 <= 1;
                    end else if (done_mont3) begin
                        C <= out_C_mont3; // Final result
                        done <= 1;
                        state <= IDLE;
                        start_mont3 <= 0;
                    end
                end
            endcase
        end
    end
endmodule
