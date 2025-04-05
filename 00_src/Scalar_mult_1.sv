module ScalarMult (
    input logic i_clk,
    input logic i_rst_n,
    input logic i_start,
    input logic [255:0] k,  // Scalar k
    input logic [255:0] X, Y, Z, // Input point P
    input logic [255:0] p,  // Prime modulus
    output logic [255:0] X_out, Y_out, Z_out, // Output point kP
    output logic o_done
);

    typedef enum logic [2:0] {IDLE, INIT, WAIT_ECPA, WAIT_ECPD, DONE} state_t;
    state_t state;
    
    logic [255:0] X0, Y0, Z0; // R0
    logic [255:0] X1, Y1, Z1; // R1
    logic [255:0] X_double, Y_double, Z_double; // R_double
    logic [7:0] bit_pos;
    logic ecpa_start, ecpd_start;
    logic ecpa_done, ecpd_done;
    logic [255:0] X_ecpa, Y_ecpa, Z_ecpa;
    logic [255:0] X_ecpd, Y_ecpd, Z_ecpd;
    logic enable_add, enable_double;
    logic [255:0] X0_reg, Y0_reg, Z0_reg;
    logic [255:0] X1_reg, Y1_reg, Z1_reg;
    
    ECPA ecpa (
        .i_clk(i_clk),
        .i_rst_n(enable_add),
        .i_start(ecpa_start),
        .p(p),
        .X1(X0), .Y1(Y0), .Z1(Z0),
        .X2(X1), .Y2(Y1), .Z2(Z1),
        .X3(X_ecpa), .Y3(Y_ecpa), .Z3(Z_ecpa),
        .o_done(ecpa_done)
    );
    
    ECPD ecpd (
        .i_clk(i_clk),
        .i_rst_n(enable_double),
        .i_start(ecpd_start),
        .p(p),
        .X1(X_double), .Y1(Y_double), .Z1(Z_double),
        .X3(X_ecpd), .Y3(Y_ecpd), .Z3(Z_ecpd),
        .o_done(ecpd_done)
    );
    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= IDLE;
            o_done <= 0;
            ecpa_start <= 0;
            ecpd_start <= 0;
            X0 <= 0;
            Y0 <= 0;
            Z0 <= 0;
            X1 <= 0;
            Y1 <= 0;
            Z1 <= 0;
            enable_add <= 1;
            enable_double <= 1;
        end else begin
            case (state)
                IDLE: begin
                    if (i_start) begin
                        X0 <= 0; Y0 <= 1; Z0 <= 0; // R0 = Neutral Point
                        X1 <= X; Y1 <= Y; Z1 <= Z; // R1 = P
                        bit_pos <= 255;
                        state <= INIT;
                    end
                end
                
               
                INIT: begin
                    if (bit_pos != 0) begin
                        ecpa_start <= 1;
                        enable_add <= 1;
                        X0_reg <= X0; Y0_reg <= Y0; Z0_reg <= Z0;
                        X1_reg <= X1; Y1_reg <= Y1; Z1_reg <= Z1;                      
                        state <= WAIT_ECPA;
                    end else begin
                        X_out <= X0;
                        Y_out <= Y0;
                        Z_out <= Z0;
                        state <= DONE;
                    end
                end
                
                WAIT_ECPA: begin
                    if (ecpa_done) begin
                        ecpa_start <= 0;
                        enable_add <=0;
                        if (k[bit_pos]) begin
                            X0 <= X_ecpa; Y0 <= Y_ecpa; Z0 <= Z_ecpa;
                            X_double <= X1_reg; Y_double <= Y1_reg; Z_double <= Z1_reg;
                        end else begin
                            X1 <= X_ecpa; Y1 <= Y_ecpa; Z1 <= Z_ecpa;
                            X_double <= X0_reg; Y_double <= Y0_reg; Z_double <= Z0_reg;
                        end
                        enable_double <= 1; 
                        ecpd_start <= 1;
                        state <= WAIT_ECPD;
                    end
                        
                end
                
                WAIT_ECPD: begin
                    if (ecpd_done) begin
                        ecpd_start <= 0;
                        if (k[bit_pos]) begin
                            X1 <= X_ecpd; Y1 <= Y_ecpd; Z1 <= Z_ecpd;                     
                        end else begin
                            X0 <= X_ecpd; Y0 <= Y_ecpd; Z0 <= Z_ecpd;                     
                        end
                        bit_pos <= bit_pos - 1;
                        enable_double <= 0; 
                        state <= INIT;
                    end
                end
                
                DONE: begin
                    o_done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule