`timescale 1ns/1ps
module tb_ECC_core_1;

    logic start;
    logic i_clk;
    logic i_rst_n;
    logic [255:0] a, b, prime;
    logic [2:0] alu_sel;
    logic [255:0] alu_result;
    logic done;
    integer file;

    // Clock generation
    always #5 i_clk = ~i_clk;

    // Instantiate ECC Core
    ECC_core uut (
        .start(start),
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .a(a),
        .b(b),
        .prime(prime),
        .alu_sel(alu_sel),
        .alu_result(alu_result),
        .done(done)
    );

    initial begin
        file = $fopen("00_src/output_case_small.txt", "w");
        if (file == 0) begin
            $display("Error: Cannot open output file!");
            $finish;
        end

        i_clk = 1;
        i_rst_n = 0;
        start = 0;
        
        // Đợi reset hoàn tất
        #20;
        i_rst_n = 1;
        
        for (int i = 1; i <= 19; i++) begin
            start = 1;
            case (i)
                1:  begin a = 256'h13; b = 256'h07; prime = 256'h7F; alu_sel = 3'b001; end // ADD
                2:  begin a = 256'h2B; b = 256'h11; prime = 256'h97; alu_sel = 3'b010; end // SUB
                3:  begin a = 256'h05; b = 256'h03; prime = 256'hD3; alu_sel = 3'b011; end // MULT
                4:  begin a = 256'h0F; b = 256'h01; prime = 256'h1D; alu_sel = 3'b100; end // INV
                5:  begin a = 256'h37; b = 256'h23; prime = 256'hB5; alu_sel = 3'b011; end // MULT
                6:  begin a = 256'h2D; b = 256'h1; prime = 256'hC1; alu_sel = 3'b100; end // INV
                7:  begin a = 256'h5F; b = 256'h1B; prime = 256'hA3; alu_sel = 3'b001; end // ADD
                8:  begin a = 256'h61; b = 256'h19; prime = 256'hB9; alu_sel = 3'b010; end // SUB
                9:  begin a = 256'h29; b = 256'h17; prime = 256'hE7; alu_sel = 3'b001; end // ADD
                10: begin a = 256'h41; b = 256'h1D; prime = 256'hED; alu_sel = 3'b010; end // SUB
                11: begin a = 256'h07; b = 256'h05; prime = 256'hF7; alu_sel = 3'b011; end // MULT
                12: begin a = 256'h13; b = 256'h1; prime = 256'h23; alu_sel = 3'b100; end // INV
                13: begin a = 256'h67; b = 256'h3F; prime = 256'h11B; alu_sel = 3'b001; end // ADD
                14: begin a = 256'h53; b = 256'h31; prime = 256'h13D; alu_sel = 3'b010; end // SUB
                15: begin a = 256'h8F; b = 256'h61; prime = 256'h17B; alu_sel = 3'b011; end // MULT
                16: begin a = 256'hB3; b = 256'h7D; prime = 256'h1C9; alu_sel = 3'b001; end // ADD
                17: begin a = 256'hD7; b = 256'hA1; prime = 256'h1E7; alu_sel = 3'b010; end // SUB
                18: begin a = 256'hF5; b = 256'hC3; prime = 256'h1F3; alu_sel = 3'b011; end // MULT
                19: begin a = 256'hE9; b = 256'h1; prime = 256'h1FD; alu_sel = 3'b100; end // INV
            endcase
            
            $display("Testcase %0d:\n alu_sel = %b\n a = %h\n b = %h\n prime = %h\n", i, alu_sel, a, b, prime);
            $fdisplay(file, "Testcase %0d:\n alu_sel = %b\n a = %h\n b = %h\n prime = %h\n", i, alu_sel, a, b, prime);
            wait (done);
            $display("Result: %h\n", alu_result);
            $fdisplay(file, "Result: %h\n", alu_result);
            start = 0;
            #20;
        end
        
        $fclose(file);
        $finish;
    end
endmodule
