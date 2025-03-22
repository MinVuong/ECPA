`timescale 1ns/1ps
module tb_ECC_core_mult;

    logic start;
    logic i_clk;
    logic i_rst_n;
    logic [255:0] a, b, prime;
    logic [2:0] alu_sel;
    logic [255:0] alu_result;
    logic done;
    integer file;

    // Expected values
    logic [255:0] expected_value [0:9];

    initial begin
        expected_value[0] = 256'h0000000000000000000000000000000000000000000000000000000000000692;
        expected_value[1] = 256'h0000000000000000000000000000000000000000000000000000000000000705;
        expected_value[2] = 256'h00000000000000000000000000000000000000000000000000000000000001a0;
        expected_value[3] = 256'h0000000000000000000000000000000000000000000000000000000000000c19;
        expected_value[4] = 256'h00000000000000000000000000000000000000000000000000000000000001a0;
        expected_value[5] = 256'h000000000000000000000000000000000000000000000000000000000000158d;
        expected_value[6] = 256'h0000000000000000000000000000000000000000000000000000000000001bf6;
        expected_value[7] = 256'h0000000000000000000000000000000000000000000000000000000000000077;
        expected_value[8] = 256'h0000000000000000000000000000000000000000000000000000000000001652;
        expected_value[9] = 256'h0000000000000000000000000000000000000000000000000000000000001a93;
    end

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
        file = $fopen("11_output/output_mult_sv.txt", "w");
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
        prime = 256'd7919; // Số nguyên tố lớn

        // Test Case 1
        #100;
        i_rst_n = 0;
        #100;
        i_rst_n = 1;
        a = 256'd1009; b = 256'd2003; alu_sel = 3'b011;
        start = 1;
        wait (done);
        $display("Test Case 1: A = %h, B = %h, P = %h, Result = %h, Expected = %h", a, b, prime, alu_result, expected_value[0]);
        $fdisplay(file, "%h", alu_result);
        start = 0;
       

        // Test Case 2
        #100;
        start = 1; a = 256'd3001; b = 256'd4001; alu_sel = 3'b011;
        wait (done);
        $display("Test Case 2: A = %h, B = %h, P = %h, Result = %h, Expected = %h", a, b, prime, alu_result, expected_value[1]);
        $fdisplay(file, "%h", alu_result);
        start = 0;
        
        #100;
        // Test Case 3
        start = 1; a = 256'd5003; b = 256'd6007; alu_sel = 3'b011;
        wait (done);
        $display("Test Case 3: A = %h, B = %h, P = %h, Result = %h, Expected = %h", a, b, prime, alu_result, expected_value[2]);
        $fdisplay(file, "%h", alu_result);
        start = 0;
        
        #100;
        // Test Case 4
        start = 1; a = 256'd7001; b = 256'd7907; alu_sel = 3'b011;
        wait (done);
        $display("Test Case 4: A = %h, B = %h, P = %h, Result = %h, Expected = %h", a, b, prime, alu_result, expected_value[3]);
        $fdisplay(file, "%h", alu_result);
        start = 0;
        #100;

        // Test Case 5
        start = 1; a = 256'd5003; b = 256'd6007; alu_sel = 3'b011;
        wait (done);
        $display("Test Case 5: A = %h, B = %h, P = %h, Result = %h, Expected = %h", a, b, prime, alu_result, expected_value[4]);
        $fdisplay(file, "%h", alu_result);
        start = 0;
        #100;

        // Test Case 6
        start = 1; a = 256'd5503; b = 256'd7507; alu_sel = 3'b011;
        wait (done);
        $display("Test Case 6: A = %h, B = %h, P = %h, Result = %h, Expected = %h", a, b, prime, alu_result, expected_value[5]);
        $fdisplay(file, "%h", alu_result);
        start = 0;
        #100;

        // Test Case 7
        start = 1; a = 256'd5701; b = 256'd6709; alu_sel = 3'b011;
        wait (done);
        $display("Test Case 7: A = %h, B = %h, P = %h, Result = %h, Expected = %h", a, b, prime, alu_result, expected_value[6]);
        $fdisplay(file, "%h", alu_result);
        start = 0;
        #100;

        // Test Case 8
        start = 1; a = 256'd4003; b = 256'd5009; alu_sel = 3'b011;
        wait (done);
        $display("Test Case 8: A = %h, B = %h, P = %h, Result = %h, Expected = %h", a, b, prime, alu_result, expected_value[7]);
        $fdisplay(file, "%h", alu_result);
        start = 0;

        // Test Case 9
        #100;
        start = 1; a = 256'd4703; b = 256'd5903; alu_sel = 3'b011;
        wait (done);
        $display("Test Case 9: A = %h, B = %h, P = %h, Result = %h, Expected = %h", a, b, prime, alu_result, expected_value[8]);
        $fdisplay(file, "%h", alu_result);
        start = 0;

        // Test Case 10
        #100;
        start = 1; a = 256'd1901; b = 256'd2503; alu_sel = 3'b011;
        wait (done);
        $display("Test Case 10: A = %h, B = %h, P = %h, Result = %h, Expected = %h", a, b, prime, alu_result, expected_value[9]);
        $fdisplay(file, "%h", alu_result);
        start = 0;

        $fclose(file); 
        $finish;
    end

endmodule
