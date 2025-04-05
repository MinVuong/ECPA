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
  ECPD uut (
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
X1= 256'h69395369b5ba49f1d496e0ed15518e108f87944d735d6c5263472fe8b5ffcde9;
Y1= 256'ha9b7a27fb8d54e39c8abe441742ca54623328b79319ba69be27f2e9a3170c279;
Z1= 256'h6bc06507cec56190a39d03b401b43c8005b6e207afdf3aa106f075a0ff79683f;

p = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;


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