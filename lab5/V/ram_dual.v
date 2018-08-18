// From Altera's Dual Port RAM Example
// JRG170, VXS182
module ram_dual
(
	input [6:0] data,							// 7 bit user input
	input [10:0] read_addr, write_addr, // only need 10 bits to index the row (2048)
	input we, read_clock, write_clock,	
	output reg [6:0] q
);

	// Declare the RAM variable
	reg [6:0] ram[2047:0];
	
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
