module tb_ECC_core;

    // Inputs
    reg start;
    reg i_clk;
    reg i_rst_n;
    reg [255:0] a;
    reg [255:0] b;
    reg [255:0] prime;
    reg [255:0] n;
    reg [2:0] ecc_sel;

    // Outputs
    wire [255:0] alu_result;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    ECC_core uut (
        .start(start),
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .a(a),
        .b(b),
        .prime(prime),
        .n(n),
        .ecc_sel(ecc_sel),
        .alu_result(alu_result),
        .done(done)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 10ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        i_rst_n = 0;
        start = 0;
        a = 0;
        b = 0;
        prime = 0;
        n = 0;
        ecc_sel = 3'b000;

        // Apply reset
        #20;
        i_rst_n = 1;

        // Test case 1: ADD
        #10;
        a = 256'h23;
        b = 256'h19;
        prime = 256'h7F;
        n=256'hFF45;
        ecc_sel = 3'b001; // ADD
        start = 1;
      

        // Wait for the operation to complete
        wait(done);
      //  i_rst_n = 0;
        start = 0;
        $display("Test Case 1: ADD");
        $display("a = %h, b = %h, prime = %h, result = %h", a, b, prime, alu_result);

        // Test case 2: SUB
        #10;
        a = 256'h5A;
        b = 256'h3C;
        prime = 256'h7F;
        n=256'hFF45;
        ecc_sel = 3'b010; // SUB
        start = 1;
        i_rst_n = 1;
        
    

        // Wait for the operation to complete
        wait(done);
        start = 0;
        //i_rst_n = 0;
        $display("Test Case 2: SUB");
        $display("a = %h, b = %h, prime = %h, result = %h", a, b, prime, alu_result);

        // Test case 3: MULT
        #10;
        a = 256'h5;
        b = 256'h7;
        n=256'hFF45;
        prime = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC5;
        ecc_sel = 3'b011; // MULT
        start = 1;
        i_rst_n = 1;
        #10;
        start = 0;
        //i_rst_n = 0;

        // Wait for the operation to complete
        wait(done);
        $display("Test Case 3: MULT");
        $display("a = %h, b = %h, prime = %h, result = %h", a, b, prime, alu_result);

        // Test case 4: INV
        #10;
        a = 256'h1;
        b = 256'h3;
        prime = 256'h7;
        n=256'hFF45;
        ecc_sel = 3'b100; // INV
        start = 1;
        i_rst_n = 1;
       
        

        // Wait for the operation to complete
        wait(done);
        start = 0;
        //i_rst_n = 0;
        $display("Test Case 4: INV");
        $display("a = %h, b = %h, prime = %h, result = %h", a, b, prime, alu_result);

        // Finish simulation
        #100;
        $finish;
    end

endmodule