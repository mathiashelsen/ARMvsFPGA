/*
 * GPIO0_D[15:0] -> data
 * GPIO0_D[16] -> we
 * GPIO0_D[17] -> oe
 * GPIO0_D[18] -> ce
 */
module ARMvsFPGA(
	HEX0_D[6:0],
	HEX1_D[6:0],
	HEX2_D[6:0],
	HEX3_D[6:0],
	CLOCK_50,
	GPIO0_D[18:0],
	LEDG[9:0]
);

input CLOCK_50;
inout [18:0]GPIO0_D;
output [6:0]HEX0_D;
output [6:0]HEX1_D;
output [6:0]HEX2_D;
output [6:0]HEX3_D;
output [9:0]LEDG;

reg [15:0] shiftReg;
reg [15:0] dataOut;
wire [15:0] dataIn;
reg dirOut; // Set D[15:0] as output when High, input when Low

assign dataIn = (~dirOut) ? GPIO0_D[15:0] : 16'hZZZZ;
assign GPIO0_D[15:0] = (dirOut) ? dataOut : 16'hZZZZ;

wire clock;
wire WE;
wire OE;
wire CE;

assign WE = GPIO0_D[16];
assign OE = GPIO0_D[17];
assign CE = GPIO0_D[18];

reg CEtoggle;

assign LEDG[0] = WE;
assign LEDG[1] = OE;
assign LEDG[2] = CE;
assign LEDG[3] = CEtoggle;

reg [1:0] WEstate;
wire WERisingEdge;			
wire WEFallingEdge;
reg [1:0] OEstate;
wire OEFallingEdge;

MasterPLL pll1 (.inclk0(CLOCK_50), .c0(clock), .locked());
segdriver ss1 (.IN(shiftReg[3:0]), .OUT(HEX0_D));
segdriver ss2 (.IN(shiftReg[7:4]), .OUT(HEX1_D));
segdriver ss3 (.IN(shiftReg[11:8]), .OUT(HEX2_D));
segdriver ss4 (.IN(shiftReg[15:12]), .OUT(HEX3_D));
	
// To detect a rising edge on WE and falling on OE
always @(posedge clock)
begin
	WEstate <= {WEstate[0], WE};
	OEstate <= {OEstate[0], OE};
end
assign WERisingEdge = WEstate[0] & ~WEstate[1]; // If the current is High and the previous is Low
assign WEFallingEdge = ~WEstate[0] & WEstate[1];
assign OEFallingEdge = ~OEstate[0] & OEstate[1]; // If the current is Low and the previous is High

always @(negedge clock)
begin
	if( ~CE )
	begin
		CEtoggle <= 1'b0;
		if(OEFallingEdge)
		begin
			dirOut <= 1'b1;
			dataOut <= shiftReg;
		end
		else if(WEFallingEdge)
			dirOut <= 1'b0;
		else if(WERisingEdge)
			shiftReg <= dataIn;
	end
end

endmodule