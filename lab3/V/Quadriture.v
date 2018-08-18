// JRG170, VXS182

/**
 * Utilizes the encoder feedback from the motor to
 * adjust frequency and amplitude levels
 *
 * Pipes results to the NCO
 */
module Quadriture 
	(
	
		input A,                      // Feedback from motor
		input B,                      // Feedback from motor
		input clk,                    // 50 MHz clock
		input encoder_setting,        // Determines frequency vs amplitude
		input reset,                  // Resets output settings to 1kHz and full amplitude
		
		output [31 : 0] frequency,         // The frequency as determined by the encoder
		output [11 : 0] amplitude			  // The amplitude as determined by the encoder
	
	);
	
	// Parameters: ** Currently incorporates no control bounds for overflow **
	parameter maxAmp = 12'hfff;
	parameter minAmp = 12'h000;
	parameter maxFreq = 32'd2_147_483_648;
	parameter minFreq = 32'd2_147_483;
	
	// REG/WIRE Declarations
	reg DFlopA, DFlopB, LastA;
	reg [31 : 0] holdFrequency;                // Holds the frequency in a register
	reg [11 : 0] holdAmplitude;					 // Holds the amplitude in a register
	wire count, up;
	
	// Assignments
	assign count = ~LastA & DFlopA;            // Decides if the counter should be enabled
	assign up = DFlopB;                        // Decides which direction the motor is turning
	assign amplitude = holdAmplitude;          // Pipes the amplitude register to the output
	assign frequency = holdFrequency;          // Pipes the frequency register to the output
	
	// Register logic
	always @(posedge clk) begin
		DFlopA <= A;
		DFlopB <= B;
		LastA <= DFlopA;
		if (reset) begin
			holdAmplitude <= maxAmp;              // assign amplitude to 100%
			holdFrequency <= 32'd107374182;					// assign frequency to 1KHz
		end else if (count && up && encoder_setting && holdAmplitude < maxAmp) begin						// Increments amplitude as long as it is not max
			holdAmplitude <= holdAmplitude + 12'd1;
			holdFrequency <= holdFrequency;
		end else if (count && ~up && encoder_setting && holdAmplitude > minAmp) begin 		// Decrements amplitude as long as it is not min
			holdAmplitude <= holdAmplitude - 12'd1;
			holdFrequency <= holdFrequency;
		end else if (count && up && ~encoder_setting && holdFrequency < maxFreq) begin 		// Increments frequency as long as it is not max
			holdFrequency <= holdFrequency + 32'd16384;
			holdAmplitude <= holdAmplitude;
		end else if (count && ~up && ~encoder_setting && holdFrequency > minFreq) begin		// Decrements frequency as long as it is not min
			holdFrequency <= holdFrequency - 32'd16384;
			holdAmplitude <= holdAmplitude;
		end else begin																								// Otherwise, hold
			holdFrequency <= holdFrequency;
			holdAmplitude <= holdAmplitude;
		end
	end
	
endmodule