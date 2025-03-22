module mont_final (
    input clk,
    input rst_n,
    input start,
    input [255:0] A,
    input [255:0] B,
    input [255:0] P,
    output reg [255:0] M,
    output reg done

);
//reg [255:0] r_2;
// assign r_2 = 256'd565;
reg enable;
wire done_mont1;
reg [255:0] M_mont1, M_mont2;
reg [255:0] In_Mont_2;
reg [8:0] counter_main;
assign In_Mont_2 = M_mont1;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter_main <=1'b0;
        end
    else begin
        if (start) begin
        counter_main <= counter_main +1'b1;
        end
    end
end


montgomery mont1 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .A(A),
        .B(B),
        .P(P),
        .M(M_mont1),
        .done(done_mont1)
    );


    reg start_mont2;
    reg done_mont2;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start_mont2 <= 1'b0;
    end else begin
        if (counter_main == 9'd273) begin
        start_mont2 <= 1'b1;
    end
end
end
 
    montgomery mont2 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_mont2),
        .A(In_Mont_2),
        .B(256'h5a4),
        .P(P),
        .M(M_mont2),
        .done(done_mont2)
    );
    //assign M = M_mont2 ; 
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            enable<=0;
        end
        if (start) begin
            enable <=0;
        end
        if ((done==1)&&(start=0)) begin
            enable <=1'b1;
        end
      
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            M<=0;
            done<=0;
        end
        else begin
            M<=M_mont2;
            done<=done_mont2;
            end
    end

endmodule