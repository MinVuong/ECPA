`timescale 1ns/1ps
module tb_ECC_core;

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
        file = $fopen("00_src/output.txt", "w");
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
                1:  begin a = 256'h23; b = 256'h19; prime = 256'h7F; alu_sel = 3'b001; end // ADD
                2:  begin a = 256'h5A; b = 256'h3C; prime = 256'h7F; alu_sel = 3'b010; end // SUB
                3:  begin a = 256'h5; b = 256'h7; prime = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5; alu_sel = 3'b011; end // MULT
                4:  begin a = 256'h1; b = 256'h3; prime = 256'h7; alu_sel = 3'b100; end // INV
                5:  begin a = 256'hF1234567890AB; b = 256'hABCDE1234567; prime = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5; alu_sel = 3'b011; end // MULT
                6:  begin a = 256'h1; b = 256'hA1B2C3D4E5F60; prime = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5; alu_sel = 3'b100; end // INV
                7:  begin a = 256'hFFFFFFFFFFFFE1; b = 256'hE; prime = 256'hFFFFFFFFFFFFF7; alu_sel = 3'b001; end // ADD
                8:  begin a = 256'hFFFFFFFFFFFFDA; b = 256'h123456789ABCD; prime = 256'hFFFFFFFFFFFFEF; alu_sel = 3'b010; end // SUB
                9:  begin a = 256'h37; b = 256'h19; prime = 256'hA7; alu_sel = 3'b001; end // ADD
                10: begin a = 256'h89; b = 256'h45; prime = 256'hC1; alu_sel = 3'b010; end // SUB
                11: begin a = 256'hC; b = 256'h9; prime = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5; alu_sel = 3'b011; end // MULT
                12: begin a = 256'h1; b = 256'hB; prime = 256'h1F; alu_sel = 3'b100; end // INV
                13: begin a = 256'h59A3B; b = 256'h7C2D; prime = 256'hFFFFFFFFFFFFFD; alu_sel = 3'b001; end // ADD
                14: begin a = 256'h29D1; b = 256'h53C7; prime = 256'hFFFFFFFFFFFFF1; alu_sel = 3'b010; end // SUB
                15: begin a = 256'hABCDE; b = 256'h12345; prime = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5; alu_sel = 3'b011; end // MULT
                // Thêm 4 case số lớn gần tối đa
                16: begin a = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE; b = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD; prime = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5; alu_sel = 3'b001; end // ADD
                17: begin a = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC; b = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA; prime = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5; alu_sel = 3'b010; end // SUB
                18: begin a = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8; b = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4; prime = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5; alu_sel = 3'b011; end // MULT
                19: begin a = 256'h1; b = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2; prime = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5; alu_sel = 3'b100; end // INV
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
