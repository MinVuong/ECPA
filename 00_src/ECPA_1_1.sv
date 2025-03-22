module ECPA (
    input         clk_i,
    input         rst_ni,
    input         start,
    input  [255:0] prime,
    // P = (X1, Y1, Z1)
    input  [255:0] X1,
    input  [255:0] Y1,
    input  [255:0] Z1,
    // Q = (X2, Y2, Z2)
    input  [255:0] X2,
    input  [255:0] Y2,
    input  [255:0] Z2,
    // R = (X3, Y3, Z3)
    output reg [255:0] X3,
    output reg [255:0] Y3,
    output reg [255:0] Z3,
    output reg         done
);

  //-------------------------------------------------------------------------
  // 1. FSM State Definition
  //-------------------------------------------------------------------------
  typedef enum logic [5:0] {
    STATE_IDLE,
    // state 1 – Các phép nhân liên quan đến Z
    STATE_Z1Z2,       STATE_WAIT_Z1Z2,  // Z1Z2 = Z1 * Z2
    STATE_Z1_SQ,      STATE_WAIT_Z1_SQ, // Z1_sq = Z1 * Z1
    STATE_Z2_SQ,      STATE_WAIT_Z2_SQ, // Z2_sq = Z2 * Z2
    // state 2 – Tính mũ 3 và U
    STATE_Z1_CUBE,    STATE_WAIT_Z1_CUBE, // Z1_cube = Z1_sq * Z1
    STATE_Z2_CUBE,    STATE_WAIT_Z2_CUBE, // Z2_cube = Z2_sq * Z2
    STATE_U1,         STATE_WAIT_U1,      // U1 = X1 * Z2_sq
    STATE_U2,         STATE_WAIT_U2,      // U2 = X2 * Z1_sq
    // state 3 – Tính S và H
    STATE_S1,         STATE_WAIT_S1,      // S1 = Y1 * Z2_cube
    STATE_S2,         STATE_WAIT_S2,      // S2 = Y2 * Z1_cube
    STATE_H,          STATE_WAIT_H,       // H = U2 - U1
    // state 4 – Tính R_val và Z3
    STATE_R,          STATE_WAIT_R,       // R_val = S2 - S1
    STATE_Z3,         STATE_WAIT_Z3,      // Z3 = Z1Z2 * H
     STATE_H_SQ,       STATE_WAIT_H_SQ,    // H_sq = H * H
    // state 5 – Tính H_sq và H_cube
    STATE_V,     STATE_WAIT_V,  // V= U1H_sq = U1 * H_sq
    STATE_H_CUBE,     STATE_WAIT_H_CUBE,  // H_cube = H_sq * H = G
    STATE_R_SQ,       STATE_WAIT_R_SQ,    // R_sq = R_val * R_val
    // state 6 – Tính R_sq và U1H_sq
    STATE_TWOV, STATE_WAIT_TWOV,  // 2*V
    STATE_R_SQ_ADD_G, STATE_WAIT_R_SQ_ADD_G, // R^2+G
    // state 7 – Tính  X3
    STATE_X3,         STATE_WAIT_X3,      // X3 = R_sq - H_cube - 2*U1H_sq
    // state 8 – Tính V-X3
    STATE_V_SUB_X3,         STATE_WAIT_V_SUB_X3,      // V-X3
    //state 9 - Tinh Y3
    STATE_Y3 , STATE_WAIT_Y3, //Y3 = R.(V-X3)
    //state 10 - Done
    STATE_DONE
  } state_t;

  state_t current_state, next_state;

  //-------------------------------------------------------------------------
  // 2. Registers lưu kết quả trung gian
  //-------------------------------------------------------------------------
   // Thanh ghi trung gian

    //state 1
    reg [255:0] Z1Z2;   // Z1 * Z2
  reg [255:0] Z1_sq;  // Z1^2
  reg [255:0] Z2_sq;  // Z2^2

  // state 2
  reg [255:0] Z1_cube; // Z1^3
  reg [255:0] Z2_cube; // Z2^3
  reg [255:0] U1;      // U1 = X1 * Z2_sq
  reg [255:0] U2;      // U2 = X2 * Z1_sq

  // state 3
  reg [255:0] S1;      // S1 = Y1 * Z2_cube
  reg [255:0] S2;      // S2 = Y2 * Z1_cube
  reg [255:0] H;       // H = U2 - U1

  // state 4
  reg [255:0] R;   // R = S2 - S1
  reg [255:0] H_sq;
  reg [255:0] temp_Z3; // Z3 = H.Z1.Z2
  // state 5 
   reg [255:0] H_cube; // G = H^3 
   reg [255:0] V; // V =U1*H^2
   reg [255:0] R_sq;
   reg [255:0] r_sq_add_g;
   // state 6 
   reg [255:0] twoV; //2*V
   reg [255:0] temp_X3; // R^2 + G 
   // state 7
      // lấy temp_X3 - 2V --> temp_X3
   // state 8 
   reg [255:0] temp_Y3; // temp_Y3 = V- temp X3
   // state 9
    // lấy temp Y3 * R 
  //-------------------------------------------------------------------------
  // 3. Shared Arithmetic Modules
  // Mỗi module được dùng lại; các tín hiệu đầu vào được định tuyến bởi FSM.
  //-------------------------------------------------------------------------

  // --- Modular Multiplication (shared)
  reg         start_mul;
  reg [255:0] mul_A, mul_B;
  wire [255:0] mul_result;
  reg         done_mul;

  mont_final mult_inst (
    .start(start_mul),
    .clk(clk_i),
    .rst_n(rst_ni),
    .A(mul_A),
    .B(mul_B),
    .P(prime),
    .M(mul_result),
    .done(done_mul)
  );

  // --- Modular Subtraction (shared)
  reg         start_sub;
  reg [255:0] sub_A, sub_B;
  wire [255:0] sub_result;
  reg         done_sub;

  modular_subtractor sub_inst (
    .i_start(start_sub),
    .i_clk(clk_i),
    .i_rst_n(rst_ni),
    .A(sub_A),
    .B(sub_B),
    .p(prime),
    .result(sub_result),
    .done(done_sub)
  );

  // --- Modular Addition (shared) – dùng khi cần cộng (ví dụ nhân đôi)
  reg         start_add;   
  reg [255:0] add_A, add_B;
  wire [255:0] add_result;
  reg         done_add;

  modular_addition add_inst (
    .i_start(start_add),
    .i_clk(clk_i),
    .i_rst_n(rst_ni),
    .A(add_A),
    .B(add_B),
    .p(prime),
    .result(add_result),
    .done(done_add)
  );


  reg done_add_reg, done_sub_reg, done_mul_reg;
 
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      done_add_reg<=0;
      done_mul_reg<=0;
      done_sub_reg <=0;
    end
    else begin
      done_add_reg <= done_add;
      done_mul_reg <= done_mul;
      done_sub_reg <= done_sub;
    end
  end
  
  //-------------------------------------------------------------------------
  // 4. State Register Update
  //-------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)
      current_state <= STATE_IDLE;
    else
      current_state <= next_state;
  end

  //-------------------------------------------------------------------------
  // 5. Next State Logic: chuyển state khi các tín hiệu done của phép tính đã bằng 1
  //-------------------------------------------------------------------------
  always_comb begin
    next_state = current_state;
    case (current_state)
      STATE_IDLE:         if (start) next_state = STATE_Z1Z2;
      // state 1:
      STATE_Z1Z2:         next_state = STATE_WAIT_Z1Z2;
      STATE_WAIT_Z1Z2:    if (done_mul_reg) next_state = STATE_Z1_SQ;
      STATE_Z1_SQ:        next_state = STATE_WAIT_Z1_SQ;
      STATE_WAIT_Z1_SQ:   if (done_mul_reg) next_state = STATE_Z2_SQ;
      STATE_Z2_SQ:        next_state = STATE_WAIT_Z2_SQ;
      STATE_WAIT_Z2_SQ:   if (done_mul_reg) next_state = STATE_Z1_CUBE;
      // state 2:
      STATE_Z1_CUBE:      next_state = STATE_WAIT_Z1_CUBE;
      STATE_WAIT_Z1_CUBE: if (done_mul_reg) next_state = STATE_Z2_CUBE;
      STATE_Z2_CUBE:      next_state = STATE_WAIT_Z2_CUBE;
      STATE_WAIT_Z2_CUBE: if (done_mul_reg) next_state = STATE_U1;
      STATE_U1:           next_state = STATE_WAIT_U1;
      STATE_WAIT_U1:      if (done_mul_reg) next_state = STATE_U2;
      STATE_U2:           next_state = STATE_WAIT_U2;
      STATE_WAIT_U2:      if (done_mul_reg) next_state = STATE_S1;
      // state 3:
      STATE_S1:           next_state = STATE_WAIT_S1;
      STATE_WAIT_S1:      if (done_mul_reg) next_state = STATE_S2;
      STATE_S2:           next_state = STATE_WAIT_S2;
      STATE_WAIT_S2:      if (done_mul_reg) next_state = STATE_H;
      STATE_H:            next_state = STATE_WAIT_H;
      STATE_WAIT_H:       if (done_sub_reg) next_state = STATE_R;
      // state 4:
      STATE_R:            next_state = STATE_WAIT_R;
      STATE_WAIT_R:       if (done_sub_reg) next_state = STATE_Z3;
      STATE_Z3:           next_state = STATE_WAIT_Z3;
      STATE_WAIT_Z3:      if (done_mul_reg) next_state = STATE_H_SQ;
      // state 5:
      STATE_H_SQ:         next_state = STATE_WAIT_H_SQ;
      STATE_WAIT_H_SQ:    if (done_mul_reg) next_state = STATE_H_CUBE;
      STATE_H_CUBE:       next_state = STATE_WAIT_H_CUBE;
      STATE_WAIT_H_CUBE:  if (done_mul_reg) next_state = STATE_R_SQ;
      STATE_R_SQ:         next_state = STATE_WAIT_R_SQ;
      STATE_WAIT_R_SQ:    if (done_mul_reg) next_state = STATE_TWOV;
      // state 6:
      STATE_TWOV:          next_state = STATE_WAIT_TWOV;
      STATE_WAIT_TWOV:      if (done_mul_reg) next_state = STATE_R_SQ_ADD_G;
      STATE_R_SQ_ADD_G:     next_state = STATE_WAIT_R_SQ_ADD_G;
      STATE_WAIT_R_SQ_ADD_G: if (done_add_reg) next_state = STATE_X3;
      // state 7:
      STATE_X3:           next_state = STATE_WAIT_X3;
      STATE_WAIT_X3:      if (done_sub_reg) next_state = STATE_V_SUB_X3;
      // state 8:
      STATE_V_SUB_X3:      next_state = STATE_WAIT_V_SUB_X3;
      STATE_WAIT_V_SUB_X3: if (done_sub_reg) next_state = STATE_Y3;
      // state 9 
      STATE_Y3:           next_state = STATE_WAIT_Y3;
      STATE_WAIT_Y3:      if (done_mul_reg) next_state = STATE_DONE;
      //state 10
      STATE_DONE:         if (!start) next_state = STATE_IDLE;
      default:            next_state = STATE_IDLE;
    endcase
  end

  //-------------------------------------------------------------------------
  // 6. Output Logic & Resource Sharing: FSM điều phối các module con
  //-------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      done <= 1'b0;
      //X3 <= 0; Y3 <= 0; Z3 <= 0;
      // Reset các biến trung gian
      //state 1
      Z1Z2 <= 0; Z1_sq <= 0; Z2_sq <= 0;
      //state 2
      Z1_cube <= 0; Z2_cube <= 0; U1 <= 0; U2 <= 0;
      // state 3
      S1 <= 0; S2 <= 0; H <= 0;
      //state 4 
      R <= 0; H_sq <= 0; temp_Z3 <= 0; 
      //state 5
      H_cube <= 0; V <= 0; R_sq <=0 ; r_sq_add_g <=0;
      //state 6
      twoV <=0 ; temp_X3 <=0;
      //state 7
      //state 8 
      temp_Y3 <=0; 

      // Reset tín hiệu điều khiển
      start_mul <= 1'b0;
      start_sub <= 1'b0;
      start_add <= 1'b0;
      //done_mul_reg <=1'b0;
     // done_add_reg<=1'b0;
      //done_sub_reg <=1'b0;
  

    end else begin
      case (current_state)
        //-------------------------------------------------------------------------
        // STATE_IDLE
        //-------------------------------------------------------------------------
        STATE_IDLE: begin
          done <= 1'b0;
        end

        //-------------------------------------------------------------------------
        // state 1: Tính Z1Z2, Z1_sq, Z2_sq sử dụng module nhân (resource sharing)
        //-------------------------------------------------------------------------
        STATE_Z1Z2: begin
          // Chọn toán hạng cho Z1Z2 = Z1 * Z2
          mul_A <= Z1;    // Lưu ý: bạn có thể sử dụng X1 hoặc Z1 tùy vào sơ đồ – ở đây ví dụ minh họa 
          mul_B <= Z2;
          start_mul <= 1'b1;
        end
        STATE_WAIT_Z1Z2: begin
          
          if (done_mul_reg) begin
            Z1Z2 <= mul_result;
            start_mul <= 1'b0;
         

          end
        end

        STATE_Z1_SQ: begin
          // Tính Z1_sq = Z1 * Z1
          mul_A <= Z1;
          mul_B <= Z1;
          start_mul <= 1'b1;
        end
        STATE_WAIT_Z1_SQ: begin
          if (done_mul_reg) begin
            Z1_sq <= mul_result;
            start_mul <= 1'b0;
          end
        end

        STATE_Z2_SQ: begin
          // Tính Z2_sq = Z2 * Z2
          mul_A <= Z2;
          mul_B <= Z2;
          start_mul <= 1'b1;
        end
        STATE_WAIT_Z2_SQ: begin
          if (done_mul_reg) begin
            Z2_sq <= mul_result;
            start_mul <= 1'b0;
          end
        end

        //-------------------------------------------------------------------------
        // state 2: Tính Z1_cube, Z2_cube, U1, U2
        //-------------------------------------------------------------------------
        STATE_Z1_CUBE: begin
          // Z1_cube = Z1_sq * Z1
          mul_A <= Z1_sq;
          mul_B <= Z1;
          start_mul <= 1'b1;
        end
        STATE_WAIT_Z1_CUBE: begin
          if (done_mul_reg) begin
            Z1_cube <= mul_result;
            start_mul <= 1'b0;
          end
        end

        STATE_Z2_CUBE: begin
          // Z2_cube = Z2_sq * Z2
          mul_A <= Z2_sq;
          mul_B <= Z2;
          start_mul <= 1'b1;
        end
        STATE_WAIT_Z2_CUBE: begin
          if (done_mul_reg) begin
            Z2_cube <= mul_result;
            start_mul <= 1'b0;
          end
        end

        STATE_U1: begin
          // U1 = X1 * Z2_sq
          mul_A <= X1;
          mul_B <= Z2_sq;
          start_mul <= 1'b1;
        end
        STATE_WAIT_U1: begin
          if (done_mul_reg) begin
            U1 <= mul_result;
            start_mul <= 1'b0;
          end
        end

        STATE_U2: begin
          // U2 = X2 * Z1_sq
          mul_A <= X2;
          mul_B <= Z1_sq;
          start_mul <= 1'b1;
        end
        STATE_WAIT_U2: begin
          if (done_mul_reg) begin
            U2 <= mul_result;
            start_mul <= 1'b0;
          end
        end

        //-------------------------------------------------------------------------
        // state 3: Tính S1, S2 và H
        //-------------------------------------------------------------------------
        STATE_S1: begin
          // S1 = Y1 * Z2_cube
          mul_A <= Y1;
          mul_B <= Z2_cube;
          start_mul <= 1'b1;
        end
        STATE_WAIT_S1: begin
          if (done_mul_reg) begin
            S1 <= mul_result;
            start_mul <= 1'b0; 
          end
        end

        STATE_S2: begin
          // S2 = Y2 * Z1_cube
          mul_A <= Y2;
          mul_B <= Z1_cube;
          start_mul <= 1'b1;
        end
        STATE_WAIT_S2: begin
          if (done_mul_reg) begin
            S2 <= mul_result;
            start_mul <= 1'b0;
          end
        end

        STATE_H: begin
          // H = U2 - U1
          sub_A <= U1;
          sub_B <= U2;
          start_sub <= 1'b1;
        end
        STATE_WAIT_H: begin
          if (done_sub_reg) begin
            H <= sub_result;
            start_sub <= 1'b0;
          end
        end

        //-------------------------------------------------------------------------
        // state 4: Tính R_val và Z3
        //-------------------------------------------------------------------------
        STATE_R: begin
          // R_val = S2 - S1
          sub_A <= S1;
          sub_B <= S2;
          start_sub <= 1'b1;
        end
        STATE_WAIT_R: begin
          if (done_sub_reg) begin
            R <= sub_result;
            start_sub <= 1'b0;
          end
        end

        STATE_Z3: begin
          // Z3 = Z1Z2 * H
          mul_A <= Z1Z2;
          mul_B <= H;
          start_mul <= 1'b1;
        end
        STATE_WAIT_Z3: begin
          if (done_mul_reg) begin
            temp_Z3 <= mul_result;
            start_mul <= 1'b0;
          end
        end
        STATE_H_SQ: begin
          // H_sq = H * H
          mul_A <= H;
          mul_B <= H;
          start_mul <= 1'b1;
        end
        STATE_WAIT_H_SQ: begin
          if (done_mul_reg) begin
            H_sq <= mul_result;
            start_mul <= 1'b0;
          end
        end

        //-------------------------------------------------------------------------
        // state 5: Tính H_sq và H_cube
        //-------------------------------------------------------------------------
        STATE_V: begin
            mul_A <= U1;
            mul_B <= H_sq;
            start_mul <= 1'b1;
            end
        STATE_WAIT_V: begin
            if (done_mul_reg) begin
                V <= mul_result;
                start_mul <=1'b0;
                end
                end
        STATE_H_CUBE: begin
            mul_A <= H_sq;
            mul_B <= H;
            start_mul=1'b1;
            end
        STATE_WAIT_H_CUBE: begin 
            if (done_mul_reg) begin
                H_cube <= mul_result;
                start_mul <=1'b0;
                end
                end
        STATE_R_SQ: begin
          // R_sq = R_val * R_val
          mul_A <= R;
          mul_B <= R;
          start_mul <= 1'b1;
        end
        STATE_WAIT_R_SQ: begin
          if (done_mul_reg) begin
            R_sq <= mul_result;
            start_mul <= 1'b0;
          end
        end

        //-------------------------------------------------------------------------
        // state 6: Tính R_sq và U1H_sq
        //-------------------------------------------------------------------------
        STATE_TWOV: begin
          // R_sq = R_val * R_val
          mul_A <= 256'h2;
          mul_B <= V;
          start_mul <= 1'b1;
        end
        STATE_WAIT_TWOV: begin
          if (done_mul_reg) begin
            twoV <= mul_result;
            start_mul <= 1'b0;
          end
        end

        STATE_R_SQ_ADD_G: begin
          add_A <= R_sq;
          add_B <= H_cube;
          start_add <= 1'b1;
        end
        STATE_WAIT_R_SQ_ADD_G: begin
          if (done_add_reg) begin
            r_sq_add_g <= add_result;
            start_add <= 1'b0;
          end
        end

        
        //-------------------------------------------------------------------------
        // state 7: Tính X3 = R_sq - H_cube - 2 * U1H_sq
        // Thực hiện theo 2 bước: (1) tạm temp = R_sq - H_cube, (2) X3 = temp - (2 * U1H_sq)
        //-------------------------------------------------------------------------
        STATE_X3: begin
          // Bước 1: R_sq - H_cube
          sub_A <= r_sq_add_g;
          sub_B <= twoV;
          start_sub <= 1'b1;
        end
        STATE_WAIT_X3: begin
          if (done_sub_reg) begin
            temp_X3 <= sub_result;
            start_sub <= 1'b0;
            end
            end

        // state 8
        STATE_V_SUB_X3: begin
            sub_A <= V;
            sub_B <= temp_X3;
            start_sub <=1'b1;
            end
        STATE_WAIT_V_SUB_X3: begin
            if (done_sub_reg) begin
                temp_Y3 <= sub_result;
                start_sub <= 1'b0;
                end
                end
        // state 9
        STATE_Y3: begin
            mul_A <= temp_Y3;
            mul_B <= R;
            start_mul <=1'b1;
            end

        STATE_WAIT_Y3: begin 
            if (done_mul_reg) begin
                temp_Y3 <= mul_result;
                start_mul =1'b0;
                end
        end

        //-------------------------------------------------------------------------
        // DONE
        //-------------------------------------------------------------------------
        STATE_DONE: begin
          done <= 1'b1;
        end
       // default: done <= 1'b0;
    endcase
    end
end 
always @(posedge clk_i or negedge rst_ni) begin
  if (!rst_ni) begin
    X3<=0;
    Y3<=0;
    Z3<=0;
    end
    else begin
    X3<= temp_X3;
    Y3<=temp_Y3;
    Z3<= temp_Z3;
    end
    end

  

endmodule
