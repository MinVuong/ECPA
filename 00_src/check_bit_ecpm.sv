module check_bit_ecpm (
	 input logic clk, rst_n,
    input logic [255:0] data_in,
    output logic [8:0] first_one_position,
    output logic found
);

    logic [255:0] reg_data;
	logic [8:0]   reg_counter;
   logic         reg_shift_out;
	logic			  shift_out;
	logic			  en_count;
	logic 		  load;
	logic 		  en_shift;
	logic 		  reg_found;
	logic			  found_in;
    always_comb begin
        if (!rst_n)
            en_shift = 1'b0;
        else if (found_in)
            en_shift = 1'b0;
	else 
	    en_shift = 1'b1;
    end
	  always_ff @(posedge clk or negedge rst_n) begin
	  if (!rst_n) begin
			reg_data <= 256'h0;       // Reset thanh ghi về 0
			reg_shift_out <= 1'b0;    // Reset bit dịch ra về 0
			load <= 1'b1;             // Cho phép tải data_in khi reset
	  end
	  else begin
			if (load) begin
				 reg_data <= data_in;  // Tải data_in
				 reg_shift_out <= 1'b0;
				 load <= 1'b0;         // Tắt load sau lần đầu
			end
			else if (en_shift) begin
				 reg_data <= { reg_data[254:0],1'b0}; // Dịch phải liên tục
				 reg_shift_out <= reg_data[255];        // Lưu bit LSB
			end
	  end
 end	 
   assign shift_out = reg_shift_out;
	assign found_in = shift_out&1'b1;
	assign en_count = !found_in;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_counter <= 9'h0; // Reset counter về 0
        end
        else if (en_count) begin
            reg_counter <= reg_counter + 9'h1;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
           first_one_position <= 9'h0; // Reset counter về 0
        end
        else if (found) begin
             first_one_position <= 9'd255 - reg_counter + 9'h2 ;
        end
    end

    // Logic tuần tự
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_found <= 1'b0; // Reset về 0
        end
        else if (found_in) begin
            reg_found <= 1'b1; // Đặt thành 1 khi found_in = 1
        end
    end
    assign found = reg_found;
endmodule