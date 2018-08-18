// JRG170, VXS182

/**
 * The ADC module is responsible for passing the 
 * command signal into the ADC through the use
 * of a shift register
 */
module adc
	(
		input clk,								// The sclk input for the ADC
		input pulse,							// The sample rate signal for the ADC 
		input dout,								// The data output from the ADC (feedback loop)
		output din,            				// The data in signal for ADC
		output reg [11 : 0] d_to_filter,	// The data to be sent to the filter
		output cs_n,             			// The chip select signal for the ADC
		output reg valid						// The valid bit
	);

/**
 * This parameter stores the 12-bit command
 * Bit 11: Write bit
 * Bit 10: Sequence bit
 * Bit 9: Don't care
 * Bit 8-6: Address bits
 * Bit 5,4: Power mode bits
 * Bit 3: Shadow bit
 * Bit 2: Don't care
 * Bit 1: Range bit
 * Bit 0: Coding bit
 */
parameter command = 16'b10x001110x000000; 

parameter idle = 2'd0, loadReg = 2'd1, shift = 2'd2, validate = 2'd3;

reg [1 : 0] state;
reg [1 : 0] next_state;
reg [3 : 0] counter;
reg load, sync;

wire [15 : 0] filter_data; 

assign cs_n = sync;

// Initializes the ADC shift register megafunction	
shift_megafunction_adc shiftReg(.clock(clk), 
										  .data(command),
										  .load(load),
										  .shiftin(dout),
										  .q(filter_data),
										  .shiftout(din));

		
// Next state combinational logic
always @( * ) begin
	case (state)
		idle:													 // Wait for the sample signal
			if (pulse) begin
				next_state <= loadReg;
			end else begin
				next_state <= idle;
			end
		loadReg:                                   // Uses one clock cycle to load the register
				next_state <= shift;
		shift:                                     // Shifts for 16 clock cycles
			if (counter < 4'd15 ) begin
				next_state <= shift;
			end else begin
				next_state <= validate;
			end
		validate:											 // Use one clock cycle to validate the signal
			next_state <= idle;
		default: next_state <= idle;
	endcase
end

// Output combinational logic
always @( * ) begin
	case (state)
		idle: begin
			load <= 1;					// Load
			sync <= 1;					// No Sync
			valid <= 0;					// No Valid
		end
		loadReg: begin
			load <= 1;              // Load (Tell the shift register it is time to accept data)
			sync <= 1;					// No Sync
			valid <= 0;					// No Valid
		end
		shift: begin
			sync <= 0;					// Sync (Tell the ADC it is time to accept data)
			valid <= 0;					// No Valid
			load <= 0;  				// No load         				
		end
		validate: begin
			load <= 1;					// Load
			sync <= 1;					// No Sync
			valid <= 1;					// Valid (Tell the compiler that there is data ready)
		end
	endcase
end

// State transition logic
always @(posedge clk) begin
	state <= next_state;
	if (state == shift) begin
		counter <= counter + 4'd1;
		d_to_filter <= filter_data[11 : 0];      // Pulls the twelve LSBs (Ignores 0001)
	end else begin
		d_to_filter <= d_to_filter;
		counter <= counter;
	end
end		
	
endmodule