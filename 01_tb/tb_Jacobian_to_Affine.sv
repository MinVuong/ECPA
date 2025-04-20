module tb_Jacobian_to_Affine;

    // Clock and reset
    reg i_clk;
    reg i_rst_n;

    // Inputs
    reg i_start;
    reg [255:0] X_Jacobian, Y_Jacobian, Z_Jacobian, p;

    // Outputs
    wire [255:0] X_Affine, Y_Affine;
    wire o_done;

    // Instantiate the DUT (Device Under Test)
    Jacobian_to_Affine dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_start(i_start),
        .X_Jacobian(X_Jacobian),
        .Y_Jacobian(Y_Jacobian),
        .Z_Jacobian(Z_Jacobian),
        .p(p),
        .X_Affine(X_Affine),
        .Y_Affine(Y_Affine),
        .o_done(o_done)
    );

    // Clock generation
    always #5 i_clk = ~i_clk; // 10ns clock period

    // Testbench logic
    initial begin
        // Initialize signals
        i_clk = 0;
        i_rst_n = 0;
        i_start = 0;
        X_Jacobian = 256'h0;
        Y_Jacobian = 256'h0;
        Z_Jacobian = 256'h0;
        p = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F; // Example prime for secp256k1

        // Apply reset
        #20 i_rst_n = 1;

        // Test case 1: Convert a valid Jacobian point to Affine
        #10;
        X_Jacobian = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798; // Example X
        Y_Jacobian = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8; // Example Y
        Z_Jacobian = 256'h0000000000000000000000000000000000000000000000000000000000000001; // Z = 1 (already affine)
        i_start = 1;

        // Wait for o_done
        wait(o_done);
        #10;
        $display("Test Case 1:");
        $display("X_Affine = %h", X_Affine);
        $display("Y_Affine = %h", Y_Affine);

        // Test case 2: Convert another Jacobian point
        #20;
        i_start = 0;
        #10;
X_Jacobian = 256'hb86fd6b80ab0685a810a932298e80ab9e3c65c715b9c121af9f5730639d76fdc;
Y_Jacobian = 256'h4b8c3c9f5e50232496caa9f3aa682b9091a5755977e0717e38bcd91c59d041b2;
Z_Jacobian = 256'hf7d03c2832df6c93871fc86c2e27ab6c02ebdee34c7529cca318dea124ca6b0b; 
        i_start = 1;

        // Wait for o_done
        wait(o_done);
        #10;
        $display("Test Case 2:");
        $display("X_Affine = %h", X_Affine);
        $display("Y_Affine = %h", Y_Affine);

        // Finish simulation
        #20;
        $finish;
    end

endmodule