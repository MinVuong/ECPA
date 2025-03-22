module montgomery(
    input clk,
    input rst_n,
    input start,
    input [255:0] A,
    input [255:0] B,
    input [255:0] P,
    output reg [255:0] M,
     output reg done
);
    reg done_BKA, cout_BKA, start_BKA;
    reg [255:0] temp_M;
    reg cout;
    integer i;
    reg [255:0] sin_adder_1;
    reg cin_adder_1;
    wire [255:0] mul_in_adder_1;
    reg cout_adder_1;
    reg [256:0] sout_adder_1;
  
    reg [255:0] sin_adder_2;
    reg cin_adder_2;
    reg [255:0] mul_in_adder_2;
    reg cout_adder_2;
    reg [256:0] sout_adder_2;
    reg [255:0] sout_shift;
    reg cout_shift;
    reg [8:0] counter;
    reg start_count;
    reg cout_demux_final, cout_demux_return;
   
    reg [255:0] sout_demux_final, sout_demux_return;
 
   always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start_count <=0;
        end
        else begin
            start_count <= start;
        end
   end



   always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 0;
        done <= 1'b0;
         M <= 0; 
       
    end else if (start_count) begin
        if (counter <= 9'd272) begin       
            counter <= counter + 1;
           done <= 1'b0; 
            M <=temp_M;
        end 
        else begin
                done <=1'b1;
                M <=temp_M;
                counter <= counter ;
            end
        end
    end




always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
   
        sin_adder_1 <= 0;
        cin_adder_1 <= 0;
    

    end else if (start) begin
      
        sin_adder_1 <= sout_demux_return; 
     
        cin_adder_1 <= cout_demux_return;
    end
end

   




   assign  mul_in_adder_2 = sout_adder_1[0]*P;
   assign  mul_in_adder_1 = A[counter]*B;



    csa_256 csa1 (
      
        .a({255'b0,cin_adder_1}),
        .b(sin_adder_1),
        .c(mul_in_adder_1),
        .s(sout_adder_1),
        .cout(cout_adder_1)
      
    );

  
        assign sin_adder_2 = sout_adder_1 [255:0];
        assign cin_adder_2 = cout_adder_1;
 




    csa_256 csa2 (
      
        .a({255'b0,cin_adder_2}),
        .b(sin_adder_2),
        .c(mul_in_adder_2),
        .s(sout_adder_2),
        .cout(cout_adder_2)
    
    );

   
    assign sout_shift = (sout_adder_2 [255:0]) >>1;
    assign cout_shift = (cout_adder_2) >>1;




always @* begin
    
    cout_demux_return = 0;
    sout_demux_return = 0;
 

    if (start) begin
        if (counter == 9'd255) begin
            cout_demux_return = 0;
            sout_demux_return = 0;
            cout_demux_final = cout_shift;
            sout_demux_final = sout_shift;
        end 
        else if (counter > 9'd255) begin
      
            cout_demux_final = cout_demux_final;
            sout_demux_final = sout_demux_final;
        end
        else begin
            cout_demux_return = cout_shift;
            sout_demux_return = sout_shift;
        end
    end
end





    always @(*) begin
    start_BKA = 1'b0;
    if (counter >= 9'd255) begin
        start_BKA = 1'b1;
    end
end
 wire [255:0] sin_BKA,cin_BKA;
 assign sin_BKA = sout_demux_final;
 assign cin_BKA ={255'b0,cout_demux_final};

    BK256 BK256_DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_BKA),
        .A(cin_BKA),
        .B(sin_BKA),
        .Ci(1'b0),
        .S(temp_M),
        .done(done_BKA),
        .Co(cout_BKA)
    );

                


                        


  


endmodule