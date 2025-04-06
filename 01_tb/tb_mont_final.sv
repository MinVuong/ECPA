module tb_mont_final;

    // Inputs
    reg clk;
    reg rst_n;
    reg start;
    reg [255:0] A;
    reg [255:0] B;
    reg [255:0] P;

    // Outputs
    wire [255:0] M;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    mont_final uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .A(A),
        .B(B),
        .P(P),
        .M(M),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst_n = 0;
        start = 0;
        A = 0;
        B = 0;
        P = 0;

        // Apply reset
        #20;
        rst_n = 1;

        // Test case 1
        #10;
        A = 256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;
        B = 256'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210;
        P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
        start = 1;
        

        // Wait for the operation to complete
        wait(done);

        // Display the result
        $display("Test Case 1:");
        $display("A = %h", A);
        $display("B = %h", B);
        $display("P = %h", P);
        $display("M = %h", M);

        // Test case 2
        #10;
        start = 0;
        #10;
        A = 256'h1;
        B = 256'h2;
        P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
        start = 1;

        // Wait for the operation to complete
        wait(done);

        // Display the result
        $display("Test Case 2:");
        $display("A = %h", A);
        $display("B = %h", B);
        $display("P = %h", P);
        $display("M = %h", M);

        // Finish simulation
        #100;
        $finish;
    end

endmodule