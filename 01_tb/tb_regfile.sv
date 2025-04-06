module tb_regfile;

    // Inputs
    reg i_clk;
    reg i_rst_n;
    reg [4:0] rs1_addr;
    reg [4:0] rs2_addr;
    reg [4:0] wb_addr;
    reg [255:0] wb_data_1;
    reg [255:0] wb_data_2;
    reg [255:0] wb_data_3;
    reg [1:0] ecc_control;
    reg wb_wren;

    // Outputs
    wire [255:0] rs1x_data;
    wire [255:0] rs1y_data;
    wire [255:0] rs1z_data;
    wire [255:0] rs2x_data;
    wire [255:0] rs2y_data;
    wire [255:0] rs2z_data;

    // Instantiate the Unit Under Test (UUT)
    regfile uut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .wb_addr(wb_addr),
        .wb_data_1(wb_data_1),
        .wb_data_2(wb_data_2),
        .wb_data_3(wb_data_3),
        .ecc_control(ecc_control),
        .wb_wren(wb_wren),
        .rs1x_data(rs1x_data),
        .rs1y_data(rs1y_data),
        .rs1z_data(rs1z_data),
        .rs2x_data(rs2x_data),
        .rs2y_data(rs2y_data),
        .rs2z_data(rs2z_data)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 10ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        i_rst_n = 0;
        wb_wren = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        wb_addr = 0;
        wb_data_1 = 0;
        wb_data_2 = 0;
        wb_data_3 = 0;
        ecc_control = 2'b00;

        // Apply reset
        #20;
        i_rst_n = 1;

        // Test case 1: Write and read single data (ecc_control = 2'b00)
        #10;
        wb_addr = 5'd1;
        wb_data_1 = 256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;
        wb_wren = 1;
        ecc_control = 2'b00; // Single data write
        #10;
        wb_wren = 0;

        // Read back data
        rs1_addr = 5'd1;
        #10;
        $display("Test Case 1:");
        $display("rs1x_data = %h (Expected: 123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0)", rs1x_data);

        // Test case 2: Write and read multiple data (ecc_control = 2'b01)
        #10;
        wb_addr = 5'd2;
        wb_data_1 = 256'h1111111111111111111111111111111111111111111111111111111111111111;
        wb_data_2 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
        wb_data_3 = 256'h3333333333333333333333333333333333333333333333333333333333333333;
        wb_wren = 1;
        ecc_control = 2'b01; // Multiple data write
        #10;
        wb_wren = 0;

        // Read back data
        rs1_addr = 5'd2;
        rs2_addr = 5'd2;
        #10;
        $display("Test Case 2:");
        $display("rs1x_data = %h (Expected: 1111111111111111111111111111111111111111111111111111111111111111)", rs1x_data);
        $display("rs1y_data = %h (Expected: 2222222222222222222222222222222222222222222222222222222222222222)", rs1y_data);
        $display("rs1z_data = %h (Expected: 3333333333333333333333333333333333333333333333333333333333333333)", rs1z_data);

        // Test case 3: Ensure register 0 is always 0 (ecc_control = 2'b00)
        #10;
        wb_addr = 5'd0;
        wb_data_1 = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        wb_wren = 1;
        ecc_control = 2'b00; // Single data write
        #10;
        wb_wren = 0;

        // Read back data
        rs1_addr = 5'd0;
        #10;
        $display("Test Case 3:");
        $display("rs1x_data = %h (Expected: 0)", rs1x_data);
        // Test case 4: ecc_control = 2'b10 (Read with ecc_control = 2'b10)
        #10;
        ecc_control = 2'b10; // Read with ecc_control = 2'b10
        wb_wren = 1;
        wb_addr = 5'd20;
        wb_data_1 = 256'h112233;
        #10;
        wb_wren = 0;
        rs1_addr= 5'd20;
        rs2_addr= 5'd2;
        #10;
        $display("Test Case 4:");
        $display("rs1x_data = %h (Expected: 112233)", rs1x_data);
        $display("rs2x_data = %h (Expected: 11111111111111111)", rs2x_data);
        $display("rs2y_data = %h (Expected: 22222222222222222)", rs2y_data);
        $display("rs2z_data = %h (Expected: 33333333333333333)", rs2z_data);
        // Test case 5: ecc_control = 2'b11 (Read with ecc_control = 2'b11)
        #10;
        ecc_control = 2'b11; // Read with ecc_control = 2'b11
        wb_wren = 1;
        wb_addr = 5'd21;
        wb_data_1 = 256'h445566;
        #10;
        wb_wren = 0;
        rs1_addr= 5'd2;
        rs2_addr= 5'd2;
        #10;
        $display("Test Case 5:");
        $display("rs1x_data = %h (Expected: 11111111111111111)", rs1x_data);
        $display("rs1y_data = %h (Expected: 22222222222222222)", rs1y_data);
        $display("rs1z_data = %h (Expected: 33333333333333333)", rs1z_data);
        
        $display("rs2x_data = %h (Expected: 11111111111111111)", rs2x_data);
        $display("rs2y_data = %h (Expected: 22222222222222222)", rs2y_data);
        $display("rs2z_data = %h (Expected: 33333333333333333)", rs2z_data);
        



    

        // Finish simulation
        #100;
        $finish;
    end

endmodule