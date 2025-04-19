module ECPM (
    input logic i_clk,
    input logic i_rst_n,
    input logic i_start,
    input logic [255:0] k,  // Scalar k
    input logic [255:0] X, Y, Z, // Input point P
    input logic [255:0] p,  // Prime modulus
    output logic [255:0] X_out, Y_out, Z_out, // Output point kP
    output logic o_done
);

    typedef enum logic [3:0] {IDLE, INIT,INIT_2, COMPUTE, WAIT_COMPUTE, UPDATED, PRE_DONE, DONE} state_t;
    state_t state;
    
    logic [255:0] X0, Y0, Z0; // R0
    logic [255:0] X1, Y1, Z1; // R1
    logic [255:0] X_double, Y_double, Z_double; // R_double
    logic signed [8:0] bit_pos;
    logic ecpa_start, ecpd_start;
    logic ecpa_done, ecpd_done;
    //logic [255:0] X_ecpa, Y_ecpa, Z_ecpa;
    //logic [255:0] X_ecpd, Y_ecpd, Z_ecpd;
    logic [255:0] X0_in_ecpa, Y0_in_ecpa, Z0_in_ecpa;
    logic [255:0] X1_in_ecpa, Y1_in_ecpa, Z1_in_ecpa;
    logic [255:0] X_in_ecpd, Y_in_ecpd, Z_in_ecpd;
    logic [255:0] X_out_ecpd, Y_out_ecpd, Z_out_ecpd;
    logic [255:0] X_out_ecpa, Y_out_ecpa, Z_out_ecpa;

    logic enable_add, enable_double;
    logic [255:0] X0_reg, Y0_reg, Z0_reg;
    logic [255:0] X1_reg, Y1_reg, Z1_reg;
    logic [8:0] bit_pos_temp;
    
    ECPA ecpa (
        .i_clk(i_clk),
        .i_rst_n(enable_add),
        .i_start(ecpa_start),
        .p(p),
        .X1(X0_in_ecpa), .Y1(Y0_in_ecpa), .Z1(Z0_in_ecpa),
        .X2(X1_in_ecpa), .Y2(Y1_in_ecpa), .Z2(Z1_in_ecpa),
        .X3(X_out_ecpa), .Y3(Y_out_ecpa), .Z3(Z_out_ecpa),
        .o_done(ecpa_done)
    );
    
    ECPD ecpd (
        .i_clk(i_clk),
        .i_rst_n(enable_double),
        .i_start(ecpd_start),
        .p(p),
        .X1(X_in_ecpd), .Y1(Y_in_ecpd), .Z1(Z_in_ecpd),
        .X3(X_out_ecpd), .Y3(Y_out_ecpd), .Z3(Z_out_ecpd),
        .o_done(ecpd_done)
    );
    check_bit_ecpm check_bit_ecpm (
        .data_in(k),
        .first_one_position(bit_pos_temp),
        .found()
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
                if (i_start) begin
                    ecpd_start <= 1;
                    state <= INIT;
                    X_in_ecpd <= X; Y_in_ecpd <= Y; Z_in_ecpd <= Z; // R_double = P
                end
            end
            
            INIT: begin
                if (ecpd_done) begin
                    ecpd_start <= 0;
                    enable_double <= 0;
                    X1_reg <= X_out_ecpd; Y1_reg <= Y_out_ecpd; Z1_reg <= Z_out_ecpd; // R1 = 2P
                    X0_reg <= X; Y0_reg <= Y; Z0_reg <= Z; // R0 = P
                   //  bit_pos <= bit_pos_temp   ; // Bắt đầu từ bit 254
                    state <= INIT_2;
                end
            end

            INIT_2: begin 
                bit_pos <= bit_pos_temp -1 ;
                X0 <= X0_reg; Y0 <= Y0_reg; Z0 <= Z0_reg;
                X1 <= X1_reg; Y1 <= Y1_reg; Z1 <= Z1_reg;
                state <= COMPUTE;
            end



            COMPUTE: begin
                if (bit_pos >= 0) begin
                    ecpa_start <= 1;
                    ecpd_start <= 1;
                    enable_add <= 1;
                    enable_double <= 1;
                   //  X_in_ecpd <= X0; Y_in_ecpd <= Y0; Z_in_ecpd <= Z0;
                    if (k[bit_pos]) begin
                        X_in_ecpd <= X1; Y_in_ecpd <= Y1; Z_in_ecpd <= Z1;
                    end else begin
                        X_in_ecpd <= X0; Y_in_ecpd <= Y0; Z_in_ecpd <= Z0;
                    end
                    X0_in_ecpa <= X0; Y0_in_ecpa <= Y0; Z0_in_ecpa <= Z0;
                    X1_in_ecpa <= X1; Y1_in_ecpa <= Y1; Z1_in_ecpa <= Z1;                      
                    state <= WAIT_COMPUTE;
                end else begin
                    X_out <= X0;
                    Y_out <= Y0;
                    Z_out <= Z0;
                    state <= PRE_DONE;
                end
            end
            
            WAIT_COMPUTE: begin
                if (ecpa_done) begin
                    ecpa_start <= 0;
                    enable_add <= 0;
                    ecpd_start <= 0;
                    enable_double <= 0;
                      bit_pos <= bit_pos - 1;
                    if (k[bit_pos]) begin
                        X0_reg <= X_out_ecpa; Y0_reg <= Y_out_ecpa; Z0_reg <= Z_out_ecpa;
                        X1_reg <= X_out_ecpd; Y1_reg <= Y_out_ecpd; Z1_reg <= Z_out_ecpd;
                    end else begin
                        X1_reg <= X_out_ecpa; Y1_reg <= Y_out_ecpa; Z1_reg <= Z_out_ecpa;
                        X0_reg <= X_out_ecpd; Y0_reg <= Y_out_ecpd; Z0_reg <= Z_out_ecpd;
                    end
                    state <= UPDATED;
                end
            end

            UPDATED: begin
                X0 <= X0_reg; Y0 <= Y0_reg; Z0 <= Z0_reg;
                X1 <= X1_reg; Y1 <= Y1_reg; Z1 <= Z1_reg;
              
                state <= COMPUTE;
                
            end
            
            PRE_DONE: begin 
                o_done <= 1;
                state <= DONE;
            end
            
            DONE: begin
                o_done <= 0;
                state <= IDLE;
            end
        endcase
    end
end
endmodule