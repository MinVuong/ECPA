module modular_inversion(clk, rst_n, start, b, a, m, c, ready, busy, ready0);            // c = b * a^{-1} mod m
    input          clk, rst_n;
    input          start;
    input  [255:0] b, a, m;
    output [255:0] c;
    output         ready, ready0;
    output reg     busy;
    reg            ready0,  ready1;
    assign ready = ready0 ^ ready1;
    reg    [259:0] u, v, x, y, q, result;
    wire   [259:0] x_plus_m   = x + q;                                         // x + m
    wire   [259:0] y_plus_m   = y + q;                                         // y + m
    wire   [259:0] u_minus_v  = u - v;                                         // u - v
    wire   [259:0] r_plus_m   = result + q;                                    // r + m
    wire   [259:0] r_minus_m  = result - q;                                    // r - m
    wire   [259:0] r_minus_2m = result - {q[258:0],1'b0};                     // r - 2m
    assign c = r_minus_2m[259] ? r_minus_m[259] ? result[259] ? r_plus_m[255:0] :
               result[255:0] : r_minus_m[255:0] : r_minus_2m[255:0];           // c = b * a^{-1} mod m
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready0 <= 0;
            ready1 <= 0;
            busy   <= 0;
        end else begin
            ready1 <= ready0;
            if (start) begin
                u <= {4'b0,a};                                                 // u <= a
                v <= {4'b0,m};                                                 // v <= m
                x <= {4'b0,b};                                                 // x <= b
                y <= {260'b0};                                                 // y <= 0
                q <= {4'b0,m};                                                 // q <= m
                ready0 <= 0;
                ready1 <= 0;
                busy   <= 1;
            end else begin
                if (busy && ((u == 1) || (v == 1))) begin                       // finished
                    ready0 <= 1;
                    busy   <= 0;
                    if (u == 1) begin                                           // if u == 1
                        if (x[259]) begin                                       //     if x < 0
                            result <= x_plus_m;                                 //         c = x + m
                        end else begin                                          //     else
                            result <= x;                                        //         c = x
                        end
                    end else begin                                              // else
                        if (y[259]) begin                                       //     if y < 0
                            result <= y_plus_m;                                 //         c = y + m
                        end else begin          
                                                            //     else
               result <= y;                                        //         c = y
                        end
                    end
                end else begin                                                  // not finished
                    if (!u[0]) begin                                            // while u & 1 == 0
                        u <= {u[259],u[259:1]};                                 //     u = u >> 1
                        if (!x[0]) begin                                        //     if x & 1 == 0
                            x <= {x[259],x[259:1]};                             //         x = x >> 1
                        end else begin                                          //     else
                            x <= {x_plus_m[259],x_plus_m[259:1]};               //         x = (x + m) >> 1
                        end
                    end
                    if (!v[0]) begin                                            // while v & 1 == 0
                        v <= {v[259],v[259:1]};                                 //     v = v >> 1
                        if (!y[0]) begin                                        //     if y & 1 == 0
                            y <= {y[259],y[259:1]};                             //         y = y >> 1
                        end else begin                                          //     else
                            y <= {y_plus_m[259],y_plus_m[259:1]};               //         y = (y + m) >> 1
                        end
                    end
                    if ((u[0]) && (v[0])) begin                                 // two while loops finished
                        if (u_minus_v[259]) begin                               // if u < v
                            v <= v - u;                                         //     v = v - u
                            y <= y - x;                                         //     y = y - x
                        end else begin                                          // else
                            u <= u - v;                                         //     u = u - v
                            x <= x - y;                                         //     x = x - y
                        end
                    end
                end
            end
        end
    end
endmodule                                             