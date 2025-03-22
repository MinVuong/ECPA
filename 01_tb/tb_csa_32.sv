module tb_csa_32;
    reg clk, rst_n;
    reg [31:0] a, b, c;
    wire [32:0] s;
    wire cout;

    // Instantiate the DUT (Device Under Test)
    csa_32 uut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .c(c),
        .s(s),
        .cout(cout)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        a = 0;
        b = 0;
        c = 0;

        // Reset sequence
        #10 rst_n = 1;

        // Apply test vectors
        #10 a = 32'h00000001; b = 32'h00000001; c = 32'h00000001;
        #10 a = 32'hFFFFFFFF; b = 32'h00000001; c = 32'h00000001;
        #10 a = 32'hAAAAAAAA; b = 32'h55555555; c = 32'hFFFFFFFF;
        #10 a = 32'h12345678; b = 32'h9ABCDEF0; c = 32'h0FEDCBA9;
        #10 a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; c = 32'hFFFFFFFF;

        // Finish simulation
        #50 $stop;
    end

    // Monitor values
    initial begin
        $monitor("Time=%0t | a=%h b=%h c=%h | s=%h cout=%b", $time, a, b, c, s, cout);
    end
endmodule
