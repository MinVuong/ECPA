module scalar_multiplication (
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_start,
    input  logic [255:0] k,         // Scalar k
    input  logic [255:0] Px, Py, Pz, // Điểm đầu vào P (Jacobian)
    input  logic [255:0] p,          // Modulo p
    output logic [255:0] R0_X, R0_Y, R0_Z, // Kết quả kP (Jacobian)
    output logic        o_done
);

    //------------------------------------------
    // Internal Signals and State Management
    //------------------------------------------
    logic [255:0] R1_X, R1_Y, R1_Z;
    logic [255:0] next_R0_X, next_R0_Y, next_R0_Z;
    logic [255:0] next_R1_X, next_R1_Y, next_R1_Z;
    logic [7:0] bit_index;
    logic add_done, double_done;
    logic add_start, double_start;
    logic bit_k;

    // FSM States
    typedef enum logic [2:0] { 
        IDLE,       // Trạng thái chờ
        INIT,       // Khởi tạo giá trị ban đầu
        PROCESS,    // Xử lý bit hiện tại
        WAIT_ADD,   // Chờ ECPA hoàn thành
        WAIT_DOUBLE,// Chờ ECPD hoàn thành
        DONE        // Hoàn thành phép toán
    } state_t;

    state_t current_state, next_state;

    //------------------------------------------
    // State Transitions and Output Logic (FSM)
    //------------------------------------------
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            current_state <= IDLE;
            R0_X <= 256'h0;   // Điểm vô cực O = (1, 1, 0)
            R0_Y <= 256'h1;
            R0_Z <= 256'h0;
            R1_X <= 256'h0;
            R1_Y <= 256'h0;
            R1_Z <= 256'h0;
            bit_index <= 255;
            o_done <= 0;
        end else begin
            current_state <= next_state;
            
            // Cập nhật R0 và R1 khi ECPA hoàn thành
            if (add_done) begin
                if (bit_k) begin
                    R0_X <= next_R0_X;
                    R0_Y <= next_R0_Y;
                    R0_Z <= next_R0_Z;
                end else begin
                    R1_X <= next_R0_X;
                    R1_Y <= next_R0_Y;
                    R1_Z <= next_R0_Z;
                end
            end
            
            // Cập nhật R0 và R1 khi ECPD hoàn thành
            if (double_done) begin
                if (bit_k) begin
                    R1_X <= next_R1_X;
                    R1_Y <= next_R1_Y;
                    R1_Z <= next_R1_Z;
                end else begin
                    R0_X <= next_R1_X;
                    R0_Y <= next_R1_Y;
                    R0_Z <= next_R1_Z;
                end
            end
            
            // Reset o_done khi không ở trạng thái DONE
            if (current_state != DONE) begin
                o_done <= 0;
            end
        end
    end

    //------------------------------------------
    // Next State Logic (FSM)
    //------------------------------------------
    always_comb begin
        next_state = current_state;
        bit_k = k[bit_index];
        add_start = 0;
        double_start = 0;
        
        case (current_state)
            IDLE: begin
                if (i_start) begin
                    next_state = INIT;
                end
            end
            
            INIT: begin
                // Khởi tạo R0 = O (1,1,0), R1 = P
                R0_X = 256'h0;
                R0_Y = 256'h1;
                R0_Z = 256'h0;
                R1_X = Px;
                R1_Y = Py;
                R1_Z = Pz;
                next_state = PROCESS;
            end
            
            PROCESS: begin
                if (bit_index == 8'hFF) begin // Đã xử lý hết bit
                    next_state = DONE;
                end else begin
                    add_start = 1;      // Kích hoạt ECPA
                    double_start = 1;   // Kích hoạt ECPD
                    next_state = WAIT_ADD;
                end
            end
            
            WAIT_ADD: begin
                if (add_done) begin
                    next_state = WAIT_DOUBLE;
                end
            end
            
            WAIT_DOUBLE: begin
                if (double_done) begin
                    bit_index = bit_index - 1;
                    next_state = PROCESS;
                end
            end
            
            DONE: begin
                o_done = 1;
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end

    //------------------------------------------
    // Module Instantiations (ECPA và ECPD)
    //------------------------------------------
    ECPA point_adding (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_start(add_start),
        .X1(R0_X),
        .Y1(R0_Y),
        .Z1(R0_Z),
        .X2(R1_X),
        .Y2(R1_Y),
        .Z2(R1_Z),
        .p(p),
        .X3(next_R0_X),
        .Y3(next_R0_Y),
        .Z3(next_R0_Z),
        .o_done(add_done)
    );

    ECPD point_doubling (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_start(double_start),
        .X1(bit_k ? R1_X : R0_X), // Chọn điểm đầu vào dựa trên bit_k
        .Y1(bit_k ? R1_Y : R0_Y),
        .Z1(bit_k ? R1_Z : R0_Z),
        .p(p),
        .X3(next_R1_X),
        .Y3(next_R1_Y),
        .Z3(next_R1_Z),
        .o_done(double_done)
    );

endmodule