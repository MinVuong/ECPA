module pc (
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_en_pc_update,     //enable update pc
    input  logic [31:0] i_pc,    
    output logic [31:0] o_pc         
);

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            o_pc <= 32'h00000000;     
        else if (i_en_pc_update)
            o_pc <= i_pc;          
    end

endmodule
