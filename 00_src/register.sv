module register (
input wire clk_sys,
input wire rst_n,
input wire [127:0] data_in,
output reg [127:0] data_out
);

   logic [128:0] reg_data;

   always @(posedge clk_sys or negedge rst_n) begin
      if (~rst_n) reg_data <= 128'h0;
      else reg_data <= data_in;
   end

   assign data_out = reg_data;

endmodule