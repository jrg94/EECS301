module Quadriture 
	(
	
		input wire A,                      // Feedback from motor
		input wire B,                      // Feedback from motor
		input wire clk,                    // 50 MHz clock
		
		output reg signed [7 : 0] speed    // The speed calculated from the feedback (signed)
	
	);
	
	// REG/WIRE Declarations
	reg DFlopA, DFlopB, LastA;
	reg signed [7 : 0] counter;                // Up/Down counter that tracks ticks
	reg [18 : 0] counterOverflow;              // Controls when the reg is enabled to take in the counter total (19 bits)
	reg [7 : 0] holdSpeed;
	wire count, up;
	
	// Assignments
	assign count = ~LastA & DFlopA;
	assign up = DFlopB;
	
	// Register logic
	always @(posedge clk) begin
		counterOverflow <= counterOverflow + 1;
		DFlopA <= A;
		DFlopB <= B;
		LastA <= DFlopA;
		if (~count) begin                                                       // Covers conditions where enable is 0
			counter <= counter;
			speed <= speed;
		end else if (count && up && ~counterOverflow[18]) begin            // Covers condition for up count
			counter <= counter + 1;
			speed <= speed;
		end else if (count && ~up && ~counterOverflow[18]) begin           // Covers condition for down count
			counter <= counter - 1;
			speed <= speed;
		end else begin                          // Covers overflow condition
			speed <= counter;
			counter <= 0;
		end
	end
	
endmodule