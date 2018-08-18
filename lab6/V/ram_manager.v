// VXS182, JRG170

/**
 * The ram manager module handles 
 * the lowpass and highpass peak data
 */
module ram_manager
	(
		input read_clock,
		input write_clock,
		input valid,			// Triggers the write_index AND write enable
		input [9 : 0] x_pos, y_pos,
		input [11 : 0] peak_low,
		input [11 : 0] peak_high,
		output [11 : 0] rom_low,
		output [11 : 0] rom_high
	);
	
reg [8 : 0] write_index;
reg [8 : 0] read_index;

ram_dual high_ram(.data(peak_high),
						.read_addr(read_index),
						.write_addr(write_index),
						.we(valid),
						.read_clock(read_clock),
						.write_clock(write_clock),
						.q(rom_high));
ram_dual low_ram(.data(peak_low),
					  .read_addr(read_index),
					  .write_addr(write_index),
					  .we(valid),
					  .read_clock(read_clock),
					  .write_clock(write_clock),
					  .q(rom_low));

// write_index
always @(posedge write_clock) begin
	if (write_index == 272) begin
		write_index <= 0;
	end else if (valid) begin
		write_index <= write_index + 1'b1;
	end else begin
		write_index <= write_index;
	end
end

// read_index
always @(posedge read_clock) begin
	read_index <= write_index - y_pos;
end
	
endmodule