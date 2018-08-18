// VXS182, JRG170

/**
 * The rom manager module
 * controls a color rom
 */
module rom_manager
	(
		input clk,
		input control,
		input [11 : 0] high,
		input [11 : 0] low,
		output [23 : 0] data
	);
	
reg [7 : 0] addr;
	
color_rom rom_mod(.clk(clk),
						.addr(addr),
						.data(data));
						
always @(posedge clk) begin
	if (control) begin
		addr <= high[11 : 4];
	end else begin
		addr <= low[11 : 4];
	end
end
	
endmodule