module tb_BrentKung;



  reg [15:0] A, B;

  reg Cin;

  wire Cout;

  wire [15:0] S;

 // reg [16:0] ans;

 // reg [15:0] inputVec[100:0];

  // integer i, j, f;

  

  BrentKung bk16(A, B, Cin, S, Cout); 

  initial begin
	$fsdbDumpfile("tb_BrentKung.fsdb");
	$fsdbDumpvars(0,tb_BrentKung);

  end
  initial begin
	A=0;
	B=0;
	Cin=0;
  end

  initial begin
	A=16'hFFFF;
	B=16'hFFFF;
	Cin=0;
	#20;
	A=16'hBB;
	B=16'h7A;
	#100;
	$finish;
  end



endmodule
