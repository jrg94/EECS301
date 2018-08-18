// From Altera's Dual Port RAM Example
// JRG170, VXS182
module ram_dual
(
	input [11:0] data,							// 12-bit peak value
	input [8:0] read_addr, write_addr, 		// only need 9 bits to index the row (512)
	input we, read_clock, write_clock,	
	output reg [11:0] q
);

	// Declare the RAM variable
	reg [11:0] ram[512:0];
	
	always @ (posedge write_clock)
	begin
		// Write
		if (we)
			ram[write_addr] <= data;
	end
	
	always @ (posedge read_clock)
	begin
		// Read 
		q <= ram[read_addr];
	end
endmodule