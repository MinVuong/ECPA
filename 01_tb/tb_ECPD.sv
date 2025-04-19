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
X1= 256'h7d152c041ea8e1dc2191843d1fa9db55b68f88fef695e2c791d40444b365afc2;
Y1= 256'h56915849f52cc8f76f5fd7e4bf60db4a43bf633e1b1383f85fe89164bfadcbdb;
Z1= 256'h9075b4ee4d4788cabb49f7f81c221151fa2f68914d0aa833388fa11ff621a970;

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