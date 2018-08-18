// VXS182, JRG170

/**
 * The module which powers the motor 
 */
module pwm
	(
	
		input clk,
		input signed [7 : 0] dutyCycle, 
		
		output motorSignalA,             // Signal output to motor drive IN1
		output motorSignalB              // Signal output to motor drive IN2
	
	);
	
	// Registers
	reg pwm_state;                         // Holds the state of pwm_state
	reg signed [7 : 0] counter;            // Holds the frequency (outside of human hearing ~ 50,000 Hz)
	
	// Sets up the A and B signals
	assign motorSignalA = pwm_state;
	assign motorSignalB = ~pwm_state;
	
	// Changes pwm_state based on the duty cycle
	always @(posedge clk) begin
		counter <= counter + 1'b1;
		if (counter < dutyCycle) begin
			pwm_state <= 0;
		end else begin
			pwm_state <= 1;
		end
	end
	
endmodule