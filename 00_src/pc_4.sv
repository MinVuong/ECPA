module pc_4 (
    input  logic [31:0] i_pc_in,
    output logic [31:0] o_pc_out
);
    assign o_pc_out = i_pc_in + 32'd4; 
endmodule