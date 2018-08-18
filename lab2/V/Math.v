module Math 
	(
	
		input clk,                            // A 50 MHz clock
		input countUp,                        // Used to decrease the goal
		input countDown,                      // Used to increase the goal
		input reset,                          // Used to reset the goal to 0
		input [7 : 0] gain,                   // 8-bit unsigned constant
		input signed [7 : 0] measuredSpeed,   // The measured speed from the feedback (signed)
		
		output signed [7 : 0] dutyCycle       // The dutyCycle 
	
	);
	
	// Register assignments
	reg signed [7 : 0] goal;
	reg [19 : 0] counter;
	reg [16 : 0] temp;
	
	// Output assignment
	//assign dutyCycle = (gain * $signed(goal - measuredSpeed));   // Calculate how many ticks away from goal (error) 
	assign dutyCycle = temp >> 8;
	
	always @(posedge clk) begin
		counter <= counter + 1;
	end

	// Handles goal assignments
	always @(posedge counter[19] or posedge reset) begin
		temp = $signed({1'b0,gain}) * (goal - measuredSpeed);
		if (reset) begin
			goal <= 0;
		end else if (countUp && $signed(goal) < 127) begin
			goal <= goal + 1;
		end else if (countDown && $signed(goal) > -127) begin
			goal <= goal - 1;
		end else begin
			goal <= goal;
		end
	end
	
endmodule