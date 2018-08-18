// JRG170, VXS182

/**
 * The DAC module
 * Responsible for shifting data into DAC
 * Responsible for pulsing sync high after 32 cycles of shift
 */
module DAC
	(
		input clk,                     // Input clock
		input [11 : 0] parallelIn,     // Data from filter to be fed in parallel
		input pulse,                   // A pulse signal that queues shifting in the shift registers
		input enable,						 // An enable signal that halts the DAC output on low
		output serialOut,              // Data to be shifted out in series
		output sync					       // Sync command that signals DAC to begin shifting
	);
	
parameter loadReg = 1'd0, shift = 1'd1;

reg state;
reg next_state;
reg [4 : 0] counter;      
reg load;
reg syncOut;

wire [31 : 0] out;

assign sync = syncOut;
	
// Instantiated the megafunction as a submodule to avoid messing it up
Shift_Megafunction_DAC shiftreg(.clock(clk), 
										  .data(out), 
										  .load(load),
										  .shiftout(serialOut));	

// A conversion module that handles all data conversion for the DAC
math2DAC m2d(.ast_data_2s(parallelIn),
				 .ast_data_sbi(out));

// Next state combinational logic
always @( * ) begin
	case (state)
		loadReg:                                   // Uses one clock cycle to load the register
			if (pulse && enable) begin
				next_state <= shift;
			end else begin
				next_state <= loadReg;
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