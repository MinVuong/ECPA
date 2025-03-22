`timescale 1ns/1ps

module tb_ECDSA;
    reg clk;
    reg start;
    reg [255:0] h, key;
    wire [511:0] sign;
    wire busy;

    // Instantiate the ECDSA module
    ECDSA DUT (
        .clk(clk),
        .start(start),
        .h(h),
        .key(key),
        .sign(sign),
        .busy(busy)
    );

    // Clock generation
    always #5 clk = ~clk; // 100MHz clock

    initial begin
        // Initialize
        clk = 0;
        start = 0;
        h = 256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;
        key = 256'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210;

        // Apply stimulus
        #20 start = 1;
      

        // Wait for computation
        wait (!busy);
        
        // Display result
        $display("Signature r: %h", sign[511:256]);
        $display("Signature s: %h", sign[255:0]);

        #20 $finish;
    end

endmodule
