`timescale 1ns / 1ps

module tb_ecpd;

  // Inputs
  logic i_clk;
  logic i_rst_n;
  logic i_start;
  logic [255:0] X1;
  logic [255:0] Y1;
  logic [255:0] Z1;
  logic [255:0] p;

  // Outputs
  logic [255:0] X3;
  logic [255:0] Y3;
  logic [255:0] Z3;
  logic o_done;

  // Instantiate the Unit Under Test (UUT)
  ecpd uut (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(i_start),
    .X1(X1),
    .Y1(Y1),
    .Z1(Z1),
    .p(p),
    .X3(X3),
    .Y3(Y3),
    .Z3(Z3),
    .o_done(o_done)
  );

  // Clock generation
  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk; // Toggle clock every 5 time units
  end

  // Test sequence
  initial begin
    // Initialize Inputs
    i_rst_n = 0;
    i_start = 0;
    X1 = 0;
    Y1 = 0;
    Z1 = 0;
    p = 0;

    // Wait for global reset
    #100;
    i_rst_n = 1;

    // Apply test values
    #10;
    X1 = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    Y1 = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
    Z1 = 256'h0000000000000000000000000000000000000000000000000000000000000001;
    p = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF43;

    // Start the operation
    #10;
    i_start = 1;


    // Wait for the operation to complete
    wait(o_done == 1);

    // Display the results
    $display("Test Case 1:");
    $display("X3 = %h", X3);
    $display("Y3 = %h", Y3);
    $display("Z3 = %h", Z3);

    // Wait before next test case
    #1000;

    // End simulation
    #100;
    $finish;
  end

endmodule