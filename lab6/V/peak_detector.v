// VXS182, JRG170

/**
 * Calculates the highest value
 * over the last second
 */
module peak_detector 
	(
		input clk,
		input signed [11 : 0] lowpass_data,
		input signed [11 : 0] highpass_data,
		output reg [11 : 0] peak_high,
		output reg [11 : 0] peak_low,
		output reg valid
	);
	
reg [18 : 0] counter;
reg signed [11 : 0] peak_highpass;
reg signed [11 : 0] peak_lowpass;
	
always @(posedge clk) begin
	// Set peak high and peak low and reset everything else 
	if (counter >= 26'd333_000) begin // 20 MHz clock
		counter <= 0;
		peak_high <= peak_highpass;
		peak_low <= peak_lowpass;
		peak_highpass <= 0;
		peak_lowpass <= 0;
		valid <= 1;
	end else begin
		counter <= counter + 1'b1;
		peak_high <= peak_high;
		peak_low <= peak_low;
		valid <= 0;
		
		if (peak_highpass < highpass_data) begin
			peak_highpass <= highpass_data;
		end else begin
			peak_highpass <= peak_highpass;
		end
		
		if (peak_lowpass < lowpass_data) begin
			peak_lowpass <= lowpass_data;
		end else begin
			peak_lowpass <= peak_lowpass;
		end
	end
end
	
endmodule
	