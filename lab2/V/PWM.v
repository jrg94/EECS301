module PWM
	(
	
		input clk,
		input signed [7 : 0] dutyCycle,  // Error of ticks
		
		output motorSignalA,             // Signal output to motor drive IN1
		output motorSignalB              // Signal output to motor drive IN2
	
	);
	
	// Registers
	reg pwm;                               // Holds the state of pwm
	reg signed [9 : 0] counter;            // Holds the frequency (outside of human hearing ~ 50,000 Hz)
	
	// Sets up the A and B signals
	assign motorSignalA = pwm;
	assign motorSignalB = ~pwm;
	
	// Changes pwm based on the duty cycle
	always @(posedge clk) begin
		counter <= counter + 1;
		if (counter < dutyCycle * 4) begin
			pwm <= 1;
		end else begin
			pwm <= 0;
		end
		if (counter == 1024) begin
			counter <= 0;
		end
	end
	
endmodule