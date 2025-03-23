//'timescale 1ns/1ns
module modular_multiplication (          // p = a * b mod m
    input          clk, rst_n,
    input          start,
    input  [255:0] a, b, m,
    output reg [255:0] p,
    output    reg     ready
);
  //  output reg     busy;
  //  output reg     ready0;
    reg busy, ready0;
    reg            ready1;
    assign ready = ready0 ^ ready1;
    reg    [257:0] u, s;
    reg      [7:0] cnt;
    wire     [7:0] next_cnt = cnt + 8'd1;
    wire           bi_is_1= b[cnt];
    wire   [257:0] plus_u= s + u;                                           // s + u
    wire   [257:0] minus_m= plus_u - {2'b00,m};                             // s + u - m
    wire   [257:0] new_s= bi_is_1 ? minus_m[257] ? plus_u : minus_m : s;   // new s
    wire   [257:0] two_u={u[256:0],1'b0};                                // 2u
    wire   [257:0] two_u_m=two_u-{2'b00,m};                              // 2u - m
    wire   [257:0] new_u=two_u_m[257] ? two_u : two_u_m;                  // new u
    assign p = s[255:0];
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready0 <= 0;
            ready1 <= 0;
            busy   <= 0;
        end else begin
            ready1 <= ready0;
            if (start) begin
                u <= {2'b0,a};                                                // u <= a
                s      <= 0;                                                   // s <= 0
                ready0 <= 0;
                ready1 <= 0;
                busy   <= 1;
                cnt    <= 0;
            end else begin
                if (busy) begin
                    s <= new_s;                                                // s <= new_s;
                    if (cnt == 8'd255) begin                                  // finished
                        ready0 <= 1;
                        busy   <= 0;
                    end else begin                                             // not finished
                        u   <= new_u;                                          // u <= new_u;
                        cnt <= next_cnt;                                       // cnt++
                    end
                end
            end
        end
    end
endmodule
