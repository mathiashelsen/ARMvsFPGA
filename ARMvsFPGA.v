module ARMvsFPGA(
	SW[3:0],
	LEDG[9:0],
	HEX0_D[6:0],
	HEX1_D[6:0],
	HEX2_D[6:0],
	HEX3_D[6:0],
	BUTTON[2:0]
);

input [3:0] SW;
input [2:0]BUTTON;
output [9:0]LEDG;
output [6:0]HEX0_D;
output [6:0]HEX1_D;
output [6:0]HEX2_D;
output [6:0]HEX3_D;

reg [15:0] shiftReg;

segdriver ss1 (.IN(shiftReg[3:0]), .OUT(HEX0_D));
segdriver ss2 (.IN(shiftReg[7:4]), .OUT(HEX1_D));
segdriver ss3 (.IN(shiftReg[11:8]), .OUT(HEX2_D));
segdriver ss4 (.IN(shiftReg[15:12]), .OUT(HEX3_D));

always @(negedge BUTTON[0])
begin
	shiftReg <= {shiftReg[11:0], SW[3:0] };
end


endmodule