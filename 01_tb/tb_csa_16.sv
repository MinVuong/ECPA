module tb_csa_16;
    reg clk, rst_n;
    reg [15:0] x, y, z;
    wire [16:0] s;
    wire cout;

    // Instantiate the DUT (Device Under Test)
    csa_16 uut (
        .clk(clk),
        .rst_n(rst_n),
        .x(x),
        .y(y),
        .z(z),
        .s(s),
        .cout(cout)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        x = 0;
        y = 0;
        z = 0;

        // Reset sequence
        #10 rst_n = 1;

        // Apply test vectors
        #10 x = 16'h0001; y = 16'h0001; z = 16'h0001;
        #10 x = 16'hFFFF; y = 16'h0001; z = 16'h0001;
        #10 x = 16'hAAAA; y = 16'h5555; z = 16'hFFFF;
        #10 x = 16'h1234; y = 16'h5678; z = 16'h9ABC;
        #10 x = 16'hFFFF; y = 16'hFFFF; z = 16'hFFFF;

        // Finish simulation
        #50 $stop;
    end

    // Monitor values
    initial begin
        $monitor("Time=%0t | x=%h y=%h z=%h | s=%h cout=%b", $time, x, y, z, s, cout);
    end
endmodule
