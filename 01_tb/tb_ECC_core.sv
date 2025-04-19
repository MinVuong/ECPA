`timescale 1ns/1ps

module ECC_core_tb();

    // Inputs
    logic start;
    logic i_clk;
    logic i_rst_n;
    logic [255:0] a;
    logic [255:0] b;
    logic [255:0] prime;
    logic [255:0] n;
    logic [2:0] ecc_sel;
    
    // Outputs
    logic [255:0] alu_result;
    logic done;
    
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
        forever #5 i_clk = ~i_clk; // 100MHz clock
    end
    
    // Test cases
    initial begin
        // Initialize Inputs
        start = 0;
        i_rst_n = 0;
        a = 0;
        b = 0;
        prime = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F; // secp256k1 prime
        n = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141; // secp256k1 order
        ecc_sel = 0;
        
        // Reset system
        #20;
        i_rst_n = 1;
        #20;
        
        // Test case 1: Modular addition p
        $display("Test case 1: Modular addition");
        a = 256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;
        b = 256'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210;
        ecc_sel = 3'b000; // Addition
        start = 1;
        #10;
        start = 0;
        
        // Wait for operation to complete
        wait(done);
        $display("Result: %h", alu_result);
        #20;
        
        // Test case 2: Modular addition n
        $display("Test case 2: Modular addition (n)");
        a = 256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;
        b = 256'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210;
        ecc_sel = 3'b001; // Subtraction
        start = 1;
        #10;
        start = 0;
        
        wait(done);
        $display("Result: %h", alu_result);
        #20;

        // Test case 3: Modular subtraction p
        $display("Test case 3: Modular subtraction p");
        a = 256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;
        b = 256'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210;
        ecc_sel = 3'b010; // Subtraction
        start = 1;
        #10;
        start = 0;
        
        wait(done);
        $display("Result: %h", alu_result);
        #20;
        
        // Test case 4: Modular multiplication
        $display("Test case 4: Modular multiplication");
        a = 256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;
        b = 256'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210;
        ecc_sel = 3'b100; // Multiplication
        start = 1;
        #10;
        start = 0;
        
        wait(done);
        $display("Result: %h", alu_result);
        #20;
        
        // Test case 5: Modular inversion (using prime)
        $display("Test case 5: Modular inversion (using prime)");
        a = 256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;
        b = 256'h1; // Not used for inversion
        ecc_sel = 3'b110; // Inversion with prime
        start = 1;
        #10;
        start = 0;
        
        wait(done);
        $display("Result: %h", alu_result);
        #20;
        
        // Test case 6: Modular inversion (using n)
        $display("Test case 6: Modular inversion (using n)");
        a = 256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;
        b = 256'h1; // Not used for inversion
        ecc_sel = 3'b111; // Inversion with n (ecc_sel[0]=1)
        start = 1;
        #10;
        start = 0;
        
        wait(done);
        $display("Result: %h", alu_result);
        #20;
        
        // End simulation
        $display("All test cases completed");
        $finish;
    end
    
 

endmodule