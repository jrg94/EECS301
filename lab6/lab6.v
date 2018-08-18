// JRG170, VXS182

/**
 * The top-level module
 */
module lab6
       (
           //////////////////////// Clock Input ////////////////////////
           input CLOCK_50,
           input CLOCK_50_2,
           //////////////////////// Push Button ////////////////////////
           input [ 2: 0 ] BUTTON,
           //////////////////////// DPDT Switch ////////////////////////
           input [ 9: 0 ] SW,
           //////////////////////// 7-SEG Display ////////////////////////
           output [ 6: 0 ] HEX0_D,
           output HEX0_DP,
           output [ 6: 0 ] HEX1_D,
           output HEX1_DP,
           output [ 6: 0 ] HEX2_D,
           output HEX2_DP,
           output [ 6: 0 ] HEX3_D,
           output HEX3_DP,
           //////////////////////// LED ////////////////////////
           output [ 9: 0 ] LEDG,
           //////////////////////// GPIO ////////////////////////
           input [ 1: 0 ] GPIO0_CLKIN,
           output [ 1: 0 ] GPIO0_CLKOUT,
           inout [ 31: 0 ] GPIO0_D,
           input [ 1: 0 ] GPIO1_CLKIN,
           output [ 1: 0 ] GPIO1_CLKOUT,
           inout [ 31: 0 ] GPIO1_D
       );

// =======================================================
// REG/WIRE declarations
// =======================================================

wire sclk;							// The sample clock pulse
wire serial_out;					// The serial out feed from the DAC
wire sync;							// The sync pulse from the DAC
wire din;							// The data in signal to the ADC
wire dout;							// The data out signal from the ADC
wire cs_n;							// The chip select signal of the ADC
wire adc_valid;					// The ADC valid input signal
wire highpass_valid;				// The highpass filter valid bit
wire lowpass_valid;				// The lowpass filter valid bit
wire pulse;							// The sample clock pulse
wire enable;						// The enable signal wire for the DAC
wire motor_a;						// The power signal for the motor A input
wire motor_b;						// The power signal for the motor B input
wire dclk;							// The 9MHz clock signal
wire pll_lock;						// The 9MHz clock lock signal
wire peak_valid;					// The valid signal from the peak detector
wire valid_draw;					// The valid draw signal
wire v_blank;						// The vertical blank region signal
wire v_sync;						// The vertical sync signal
wire h_sync;						// The horizontal sync signal
wire control;
wire [7 : 0] blue, red, green;// The 8-bit color signals
wire [9 : 0] x, y;				// The 10-bit x and y position signals
wire [11 : 0] adc_out;			// The 12-bit signal to be sent out to the filters
wire [11 : 0] highpass_data;	// The ast data from the high pass filter
wire [11 : 0] lowpass_data;	// The ast data from the low pass filter
wire [11 : 0] peak_high;		// The 12-bit peak high signal
wire [11 : 0] peak_low;			// The 12-bit peak low signal
wire [11 : 0] rom_high;
wire [11 : 0] rom_low;
wire [23 : 0] color_data;		// The 24-bit color data signal

//=======================================================
// Input/Output assignments
//=======================================================
// All unused inout port turn to tri-state
assign GPIO0_D = 32'hzzzzzzzz;
assign GPIO1_D = 32'hzzzzzzzz;

assign enable = SW[0];					// Attaches Switch 0 to the enable wire

/** Motor Signals **/
assign GPIO0_D[0] = motor_a;        // Motor IN1 (AB16)  ***OUTPUT***
assign GPIO0_D[1] = motor_b;			// Motor IN2 (AA16)  ***OUTPUT***
assign GPIO0_D[2] = enable;			// The motor enable signal
assign GPIO0_D[3] = SW[1];

/** DAC Signals **/
assign GPIO0_D[6] = sclk;       		// Attaches the clock to the sclk input                              
assign GPIO0_D[7] = serial_out; 		// Attaches the serial output from the shift register module to the DAC 
assign GPIO0_D[8] = sync;				// Attaches the sync command from the shift register module to the DAC (ACTIVE LOW)
assign GPIO0_D[9] = 0;              // Attaches the LDAC pin to 0 (ACTIVE LOW)
assign GPIO0_D[10] = 0;					// Attaches the CLR pin to 0 (ACTIVE LOW)

/** ADC Signals **/
assign GPIO0_D[11] = sclk; 			// Attaches the clock to the sclk input 
assign GPIO0_D[12] = din;				// Attaches the data in signal to the data in input
assign dout = GPIO0_D[13];				// Attaches the data out signal to the data out wire
assign GPIO0_D[14] = cs_n;				// Attaches the chip select input to the chip select signal

/** Display Signals **/
assign GPIO1_D[ 27: 0 ] = { v_sync, h_sync, pll_lock, dclk, blue, green, red };

// =======================================================
// Structural coding
// =======================================================

/**
 * The ALT_PLL megafunction module which is 
 * responsible for converting the 50MHz system clock to
 * the 9MHz display clock
 */
display_clock clock_mod(.inclk0(CLOCK_50),		// 50 MHz
								.c0(dclk),					// 9 MHz
								.c1(sclk),					// 20 MHz
								.locked(pll_lock));		// Clock megafunction lock signal

/**
 * The sample pulse module which is responsible for generating
 * the sample rate pulse
 */ 
sample_clock s_clk(.clk(sclk),
						 .pulse(pulse));

/**
 * The ADC module which is responsible for converting
 *	an analog input signal to a digital signal for processing
 */ 
adc adc_mod(.clk(sclk),							// 20 MHz audio clock	
				.pulse(pulse),						// Sample clock pulse
				.dout(dout),						// The ADC output signal					
				.din(din),							// The ADC input signal
				.d_to_filter(adc_out),			// The parallel data from the ADC
				.cs_n(cs_n),						// The chip select signal 
				.valid(adc_valid));				// The ADC valid signal

/**
 * The highpass filter module which is responsible for
 * filtering out low frequency (below 500Hz) signals
 */
fir_highpass highpass_mod(.clk(sclk),									// 20 MHz audio clock
								  .reset_n(1),									// The filter reset signal
								  .ast_sink_data(adc_out),					// The 12-bit filter input signal
								  .ast_sink_valid(adc_valid),				// The ADC valid signal
								  .ast_source_ready(1),
								  .ast_source_data(highpass_data),		// The filter output data
								  .ast_source_valid(highpass_valid));	// The filter valid bit

/**
 * The lowpass filter module which is responsible for
 * filtering out high frequency (above 500 Hz) signals
 */
fir_lowpass lowpass_mod(.clk(sclk),										// 20MHz audio clock
								.reset_n(1),									// The filter reset signal
								.ast_sink_data(adc_out),					// The filter input data
								.ast_sink_valid(adc_valid),				// The ADC valid signal
								.ast_source_ready(1),
								.ast_source_data(lowpass_data),
								.ast_source_valid(lowpass_valid));
				
/**
 *	The DAC module which is responsible for converting
 *	a digital signal to an analog signal to be output
 */ 
dac dac_mod(.clk(sclk),									// 20MHz audio clock
				.parallel_in(highpass_data),			// 22 bits from high pass filter
				.pulse(highpass_valid),					// Valid signal from high pass filter
				.enable(enable),							// Enable signal from switch 0
				.serial_out(serial_out),				// Data to be output to DAC
				.sync(sync));								// Sync signal to be output to DAC

/**
 * The PWM module which is responsible for preparing the low
 * frequency signal for the motorSignal
 */ 
pwm pwm_mod(.clk(sclk),									// 20MHz audio clock
				.dutyCycle(lowpass_data[11 : 4]),	// The 8-bit speed signal
				.motorSignalA(motor_a),					// The output signal A to be sent to the motor 
				.motorSignalB(motor_b));				// The output signal B to be sent to the motor

/**
 * The peak detector module which is responsible for
 * collecting the peak value from each filter over
 * some time interval
 */
peak_detector detector_mod(.clk(sclk),										// 20 MHz audio clock
									.lowpass_data(lowpass_data),				// The low pass filter data
									.highpass_data(highpass_data),			// The high pass filter data
									.peak_high(peak_high),						// The peak high over an interval
									.peak_low(peak_low),							// The peak low over an interval
									.valid(peak_valid));
/**
 * The ram manager modules which handles data transfers
 * between two separate RAM modules
 */ 
ram_manager ram_mod(.read_clock(dclk),						// The 9MHz read (display) clock
						  .write_clock(sclk),					// The 20MHz write (sample) clock
						  .valid(peak_valid),					// The valid signal from the peak detector
						  .x_pos(x),
						  .y_pos(y),
						  .peak_low(peak_low),					// The peak value from the lowpass filter
						  .peak_high(peak_high),				// The peak value from the highpass filter
						  .rom_low(rom_low),
						  .rom_high(rom_high));

/**
 * The rom manager module which is responsible
 * for handling all color data for the waterfall plot
 */ 
rom_manager rom_mod(.clk(dclk),								// The 9MHz display clock
						  .control(control),								// The control bit
						  .high(rom_high),						// The highpass peak in-data
						  .low(rom_low),							// The lowpass peak  in-data
						  .data(color_data));					// The corresponding color

/**
 * The waterfall plot module which is responsible
 * for plotting peak data
 */ 
waterfall_plot plot_mod(.clk(dclk),							// The 9MHz display clock
								.en(enable),						// The enable signal
								.valid_region(valid_draw),		// The valid draw signal
								.v_blank(v_blank),				// The vertical blank region signal
								.color(color_data),				// The highpass color data
								.value_red(red),					// The red color data
								.value_green(green),				// The green color data
								.value_blue(blue),				// The blue color data
								.x_pos(x),							// The x position		
								.y_pos(y),							// The y position
								.control(control));
				
/**
 * The video position sync module which is responsible
 * for all timing associated with the LCD
 */ 
video_position_sync vsync_mod(.disp_clk(dclk),				// 9MHz display clock
										.en(pll_lock),					// Display enable (Use lock from clock)
										.disp_hsync(h_sync),			// Horizontal sync signal
										.disp_vsync(v_sync),			// Vertical sync signal
										.valid_draw(valid_draw),	// Valid draw bit
										.v_blank(v_blank),			// Vertical blank region signal
										.h_pos(x),						// Horizontal position signal
										.v_pos(y));						// Vertical position signal

endmodule
