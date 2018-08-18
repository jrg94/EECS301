// JRG170, VXS182

/**
 * This module is responsible for converting
 * the output of the filtering process from
 * 2s compliment to straight binary
 */
module dac_math
	(
		input signed [11 : 0] ast_data_2s,			// The two's compliment signal from the filter
		output [31 : 0] ast_data_sbi			// The straight binary interpretation of the signal
	);

parameter command = 4'b0011;
parameter address = 4'b0000;
parameter dontCare = 4'bxxxx;

wire [11 : 0] out;
	
assign ast_data_sbi = {dontCare, command, address, out, dontCare, dontCare};	// 4 bits + 4 bits + 4 bits + 12 bits + 4 bits + 4 bits;
assign out = (ast_data_2s + $signed({1'b0, 12'd2047}));                			// Adds half the max value to the signal

endmodule