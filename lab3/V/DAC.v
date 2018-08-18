// JRG170, VXS182

/**
 * Utilizes the DAC to produce sound
 */
module DAC
	(
		input LDAC,					// Hold this low for standalone mode
		input DIN,              // Serial data input
		input PDL,              // Software power-down
		input CLR,              // Asynchronous clear input
		input SYNC,             // Intializes 32 clock cycles of shift
		input SCLK              // The sample clock at the rate at which samples will be shifted
	);
	
	// Must convert input signal from 2's compliment to unsigned binary
	
endmodule