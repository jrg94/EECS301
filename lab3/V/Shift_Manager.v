// JRG170, VXS182

/** 
 * Utilizes a state machine to handle loads and shifts from
 * the NCO to the DAC
 */
module Shift_Manager
	(
		input clk,                     // Input clock
		input [31 : 0] parallelIn,     // Data from NCO to be fed in parallel
		input pulse,
		input enable,
		output serialOut,              // Data to be shifted out in series
		output sync					       // Sync command that signals DAC to begin shifting
	);
	
parameter loadReg = 2'd0, shift = 2'd1;

reg [1 : 0] state;
reg [1 : 0] next_state;
reg [4 : 0] counter;      
reg load;
reg syncOut;

assign sync = syncOut;

// Instantiated the megafunction as a submodule to avoid messing it up
ShiftReg shiftreg(.clock(clk), .data(parallelIn), .load(load), .shiftout(serialOut));

// Next state combinational logic
always @( * ) begin
	case (state)
		loadReg:                                   // Uses one clock cycle to load the register
			if (pulse && enable) begin
				next_state <= shift;
			end
		shift:                                     // Shifts for 32 clock cycles
			if (counter < 5'b11111) begin
				next_state <= shift;
			end else begin
				next_state <= loadReg;
			end
		default: next_state <= loadReg;
	endcase
end

// Output combinational logic
always @( * ) begin
	case (state)
		loadReg: begin
			load <= 1;              // High LOAD tells the shift register to begin loading data (32 bits)
			syncOut <= 1;           // High SYNC tells the DAC to ignore input			
		end
		shift: begin
			load <= 0;              // Low LOAD tells the shift register to hold off on loading data (32 bits)
			syncOut <= 0;           // Low SYNC tells the DAC to begin reading in bits
		end
	endcase
end

// State transition logic
always @(posedge clk) begin
	state <= next_state;
	if (state == shift) begin
		counter <= counter + 5'd1;
	end else begin
		counter <= counter;
	end
end
			
endmodule