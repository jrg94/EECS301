// Handles the ROM events
// JRG170, VXS182
module rom_manager
	(
		input clk,
		input [9 : 0] x_pos, y_pos,
		input [6 : 0] char,
		output [10 : 0] read_addr,
		output [7 : 0] data
	);
	
assign read_addr = x_pos[8 : 3] + (y_pos[8 : 4] * 6'd60); 	

font_rom fr(.clk(clk),
				.addr({char, y_pos[3 : 0]}), // Produces an 11-bit address; 7 from RAM and 4 from v_pos
				.data(data));
				
endmodule