//-------------------------------------------------------------------------------------------------
module ram
//-------------------------------------------------------------------------------------------------
#
(
	parameter KB = 0
)
(
	input  wire                      clock,
	input  wire                      ce,
	input  wire                      we,
	input  wire[$clog2(KB*1024)-1:0] a,
	input  wire[                7:0] d,
	output reg [                7:0] q
);
//-------------------------------------------------------------------------------------------------

reg[7:0] ram[(KB*1024)-1:0];
always @(posedge clock) if(ce) if(we) ram[a] <= d; else q <= ram[a];

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
