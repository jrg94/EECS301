// JRG170, VXS182

/**
 * Manages the data paths for the NCO megafunctions
 */
module NCO_Manager 
	(
		input [31 : 0] phi_inc_i,
		input clk,
		input clken,
		input [11 : 0] amplitude,
		output [31 : 0] fsin_o,
		output out_valid
		
	);
	
parameter command = 4'b0011;
parameter address = 4'b0000;
parameter dontCare = 4'bxxxx;
	
wire signed [11 : 0] nco_out;

wire [11 : 0] out;
wire signed [23 : 0] mult;
	
NCO_Megafunction nco(.phi_inc_i(phi_inc_i), .clk(clk), .reset_n(1), .clken(clken), .fsin_o(nco_out), .out_valid(out_valid));

/** MATH **/
/* Must perform signed multiplication */
/* Must add half max */
assign fsin_o = {dontCare, command, address, out, dontCare, dontCare}; // 4 bits + 4 bits + 4 bits + 12 bits + 4 bits + 4 bits;
assign out = (mult + $signed({1'b0, 12'd2047}));                // Adds half the max value to the amplified signal
assign mult = ((nco_out * $signed({1'b0, amplitude})) >> 12);   // Multiplies the nco signal by the amplitude
	
endmodule