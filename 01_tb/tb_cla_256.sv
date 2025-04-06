`timescale 1ns / 1ps

module tb_cla_256;

  reg  [255:0] a, b;
  reg          cin;
  wire [255:0] sum;
  wire         cout;

  // Instantiate CLA 256-bit
  cla_256 uut (
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
  );

  initial begin
    $display("Time\t\tcin\ta\t\t\t\tb\t\t\t\tsum\t\t\t\t\tcout");

    // Test 1: a = 0, b = 0, cin = 0
    a   = 256'd0;
    b   = 256'd0;
    cin = 0;
    #10;
    $display("%0t\t%b\t%h\t%h\t%h\t%b", $time, cin, a, b, sum, cout);

    // Test 2: a = 1, b = 1, cin = 0
    a   = 256'd1;
    b   = 256'd1;
    cin = 0;
    #10;
    $display("%0t\t%b\t%h\t%h\t%h\t%b", $time, cin, a, b, sum, cout);

    // Test 3: a = max, b = 1, cin = 0 (should overflow)
    a   = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    b   = 256'd1;
    cin = 0;
    #10;
    $display("%0t\t%b\t%h\t%h\t%h\t%b", $time, cin, a, b, sum, cout);

    // Test 4: a = max, b = max, cin = 1 (full overflow)
    a   = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    b   = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    cin = 1;
    #10;
    $display("%0t\t%b\t%h\t%h\t%h\t%b", $time, cin, a, b, sum, cout);

    // Test 5: Random values
    a   = 256'h1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF;
    b   = 256'h1111111111111111111111111111111111111111111111111111111111111111;
    cin = 1;
    #10;
    $display("%0t\t%b\t%h\t%h\t%h\t%b", $time, cin, a, b, sum, cout);

    $finish;
  end

endmodule
