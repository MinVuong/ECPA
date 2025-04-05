module tb_modular_subtractor;

    // Testbench signals
    logic i_start;
    logic i_clk;
    logic i_rst_n;
    logic [255:0] A;
    logic [255:0] B;
    logic [255:0] p;
    logic [255:0] result;
    logic done;

    // Expected result (in hexadecimal)
    logic [255:0] expected_value = 256'h79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28dc9d35c49d5a3b570b;

    // Instantiate the modular_addition module
    modular_subtractor uut (
        .i_start(i_start),
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .A(A),
        .B(B),
        .p(p),
        .result(result),
        .done(done)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 10ns clock period
    end

    // Test sequence
    initial begin
        // Initialize signals
        i_rst_n = 0;
        i_start = 0;

        // Reset the module
        #10;
        i_rst_n = 1;
        A=256'h25738ad301228a1922c7d0cee9a6843be7143d0a0c752a58205de16744345b3e;
        B=256'hbc3a37694b6840274e30efe1d454f62b578ca8bc9917be05bd16b17d8e348984;
        p=256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;

        // Start the addition process
        #5;
        i_start = 1; // Activate start signal
        #10;          // Wait for a clock cycle
       // i_start = 0;  // Deactivate start signal

        // Wait for the computation to finish
        #1000;

        // Display results
        $display("Result: %h", result); // Display result in hexadecimal
        $display("Expected: %h", expected_value); // Display expected value

        // Check if the result matches the expected value
        if (result === expected_value) begin
            $display("Test Passed: The result is correct.");
        end else begin
            $display("Test Failed: The result is incorrect.");
        end
        
        // Finish simulation
        #10;
        $finish;
    end

endmodule