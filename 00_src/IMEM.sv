module imem (
    input  logic [31:0] addr,        
    output logic [31:0] inst          
);

    logic [31:0] mem [0:255];         // Bộ nhớ lệnh: 256 lệnh (32-bit)

    initial begin
        $readmemh("00_src/program.hex", mem); 
    end

    assign inst = mem[addr[9:2]];

endmodule
