module Jacobian_to_Affine (
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_start,
    input  logic [255:0] X_Jacobian,
    input  logic [255:0] Y_Jacobian,
    input  logic [255:0] Z_Jacobian,
    input  logic [255:0] p,
    output logic [255:0] X_Affine,
    output logic [255:0] Y_Affine,
    output logic         o_done
);

    // Intermediate wires
    logic [255:0] Z2, Z3;
    logic [255:0] temp_x, temp_y;
    logic         done_mult1, done_mult2;
    logic         done_inv1, done_inv2;
    logic         start_mult1, start_mult2, start_inv1, start_inv2;

    typedef enum logic [2:0] {
        IDLE, CALC_Z2, CALC_Z3, INV_X, INV_Y, DONE
    } state_t;

    state_t state, next_state;
   // state_t state_d; // Thanh ghi lưu trạng thái trước đó của state

    // FSM
    always_ff @(posedge i_clk or negedge i_rst_n)
        if (!i_rst_n) state <= IDLE;
        else          state <= next_state;

    always_comb begin
        next_state = state;
        case (state)
            IDLE:    
                begin
                    if (i_start) begin
                        
                        next_state = CALC_Z2;
                    end
                end 
            CALC_Z2:  if (done_mult1) next_state = CALC_Z3;
            CALC_Z3:  if (done_mult2) next_state = INV_X;
            INV_X:    if (done_inv1) next_state = INV_Y;
            INV_Y:    if (done_inv2) next_state = DONE;
            DONE:     next_state = IDLE;
        endcase
    end
    //-------------------------------------------------------

    logic start_pulse_Z2, start_d_Z2;
    logic done_Z2;
    logic start_Z2;
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            start_d_Z2   <= 1'b0;
            start_pulse_Z2 <= 1'b0;
        end else begin
            start_d_Z2   <= i_start;                   // Lưu giá trị trước của i_start
            start_pulse_Z2 <= i_start & ~start_d_Z2;      // Chỉ bật khi i_start chuyển từ 0 -> 1
    end
    end
    assign start_Z2 = start_pulse_Z2;

    // Z2 = Z * Z
    modular_multiplication mod_mult1 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_Z2),
        .a(Z_Jacobian),
        .b(Z_Jacobian),
        .m(p),
        .p(Z2),
        .ready(done_mult1)
    );
    assign done_Z2 = done_mult1;
    //-------------------------------------------------------
    logic start_Z3;
    logic done_Z3;
    logic start_pulse_Z3, start_d_Z3;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            start_d_Z3   <= 1'b0;
            start_pulse_Z3 <= 1'b0;
        end else begin
            start_d_Z3   <= done_Z2;                   // Lưu giá trị trước của i_start
            start_pulse_Z3 <= done_Z2 & ~start_d_Z3;      // Chỉ bật khi i_start chuyển từ 0 -> 1
        end
    end
    assign start_Z3 = start_pulse_Z3;
           

    // Z3 = Z2 * Z
    modular_multiplication mod_mult2 (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_Z3),
        .a(Z2),
        .b(Z_Jacobian),
        .m(p),
        .p(Z3),
        .ready(done_mult2)
    );
    assign done_Z3 = done_mult2;
    //-------------------------------------------------------
    logic start_X_affine;
    logic done_X_affine;
    logic start_pulse_X_affine, start_d_X_affine;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            start_d_X_affine   <= 1'b0;
            start_pulse_X_affine <= 1'b0;
        end else begin
            start_d_X_affine   <= done_Z3;                   // Lưu giá trị trước của i_start
            start_pulse_X_affine <= done_Z3 & ~start_d_X_affine;      // Chỉ bật khi i_start chuyển từ 0 -> 1
        end
    end
    assign start_X_affine = start_pulse_X_affine;

    // X_affine = inv_mod(Z2, X)
    modular_inversion inv_x (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_X_affine),
        .a(Z2),
        .b(X_Jacobian),
        .m(p),
        .c(X_Affine),
        .ready(done_inv1)
    );
    assign done_X_affine = done_inv1;
    //-------------------------------------------------------
    logic start_Y_affine;
    logic done_Y_affine;
    logic start_pulse_Y_affine, start_d_Y_affine;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            start_d_Y_affine   <= 1'b0;
            start_pulse_Y_affine <= 1'b0;
        end else begin
            start_d_Y_affine   <= done_X_affine;                   // Lưu giá trị trước của i_start
            start_pulse_Y_affine <= done_X_affine & ~start_d_Y_affine;      // Chỉ bật khi i_start chuyển từ 0 -> 1
        end
    end
    assign start_Y_affine = start_pulse_Y_affine;

    // Y_affine = inv_mod(Z3, Y)
    modular_inversion inv_y (
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(start_Y_affine),
        .a(Z3),
        .b(Y_Jacobian),
        .m(p),
        .c(Y_Affine),
        .ready(done_inv2)
    );
    assign done_Y_affine = done_inv2;   
//-------------------------------------------------------

    // Done signal
    logic done_Y_affine_d; // Thanh ghi lưu trạng thái trước đó của done_Y_affine
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            done_Y_affine_d <= 0;
            o_done <= 0;
        end else begin
            done_Y_affine_d <= done_Y_affine; // Lưu trạng thái trước đó của done_stage10
            o_done <= done_Y_affine & ~done_Y_affine_d; // Bật o_done khi done_stage10 chuyển từ 0 -> 1
        end
    end
endmodule