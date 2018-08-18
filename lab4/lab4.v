// JRG170, VXS182

/**
 * lab4 is the top level module that is used
 * to oversee the input/output connections to the board and
 * between modules
 * lab4 is a "digital wire" which takes in an analog signal
 * and outputs a digital signal that is filtered
 */
module lab4
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

wire clk;								// The clock signal wire
wire pulse;								// The sample rate wire for the DAC shift register
wire enable;							// The enable signal wire for the DAC
wire serialOut;						// The serial out data wire that runs from the DAC
wire sync;								// The sync wire that commands the DAC to begin loading data
wire din;								// The serial data in signal for the ADC
wire dout;								// The serial data out signal for the ADC
wire cs_n;                       // The chip select signal for the ADC
wire bankOne;							// The bank one signal wire
wire bankTwo;							// The bank two signal wire
wire bankThree;						// The bank three signal wire
wire [1 : 0] bankNumber;         // The bank number signal bus
wire [34 : 0] fir_sat_data;      // The 35-bit bus between the filter and the saturator
wire [1 : 0] fir_sat_err;			// The 2-bit error signal between the filter and the saturator
wire fir_sat_val;						// The valid signal between filter and saturator
wire [11 : 0] twos_to_math;		// The 12-bit twos compliment signal between the math module and the saturator
wire sat_dac_val;						// The valid wire which runs from the saturator to the DAC
wire adc_valid;						// The ADC valid bit to be sent to the filter
wire sig_to_comp;						// The final output signal from the ADC
wire sclk;								// The sclk wire from the clock megafunction
wire [13 : 0] adc_to_filter;		// The 14-bit signal including the bank number to the filter
wire [11 : 0] sat_to_DAC;			// The 12-bit signal from the saturator to the DAC
wire sat_to_DAC_val;					// The valid bit from the saturator to the DAC

//=======================================================
// Input/Output assignments
//=======================================================
// All inout port turn to tri-state
assign GPIO0_D = 32'hzzzzzzzz;
assign GPIO1_D = 32'hzzzzzzzz;

assign clk = CLOCK_50;
assign bankOne = ~BUTTON[0]; 					// Connects button 0 to the bank one wire
assign bankTwo = ~BUTTON[1];					// Connects button 1 to the bank two wire
assign bankThree = ~BUTTON[2];				// Connects button 2 to the bank three wire
assign enable = SW[1];							// Attaches Switch 0 to the enable wire

/** DAC INPUTS **/
assign GPIO0_D[6] = sclk;           // Attaches the clock to the sclk input                              
assign GPIO0_D[7] = serialOut; 		// Attaches the serial output from the shift register module to the DAC 
assign GPIO0_D[8] = sync;				// Attaches the sync command from the shift register module to the DAC (ACTIVE LOW)
assign GPIO0_D[9] = 0;              // Attaches the LDAC pin to 0 (ACTIVE LOW)
assign GPIO0_D[10] = 0;					// Attaches the CLR pin to 0 (ACTIVE LOW)
/** DAC INPUTS **/

/** ADC IN/OUT **/
assign GPIO0_D[11] = sclk; 			// Attaches the clock to the sclk input 
assign GPIO0_D[12] = din;				// Attaches the data in signal to the data in input
assign dout = GPIO0_D[13];				// Attaches the data out signal to the data out wire
assign GPIO0_D[14] = cs_n;				// Attaches the chip select input to the chip select signal
/** ADC IN/OUT **/


// =======================================================
// Structural coding
// =======================================================

// The sample rate clock module (80ksps)
sample_clock samp_clk(.clk(sclk),
							 .pulse(pulse));

// The 20MHz clock from the 50MHz clock						
Clock_Megafunction clk_mega(.areset(),
									 .inclk0(clk),			// 50MHz in clock
									 .c0(sclk),				// 20MHz out clock
									 .locked());
// The initial stage of lab4
// Takes the system clock and begins loading the ADC
ADC adc(.clk(sclk),
		  .pulse(pulse),
		  .dout(dout),
		  .din(din),
		  .d_to_filter(twos_to_math),
		  .cs_n(cs_n),
		  .valid(adc_valid));

// The final output stage of lab4
DAC dac(.clk(sclk), 
		  .parallelIn(twos_to_math), 
		  .pulse(adc_valid),    // sat_dac_val
		  .enable(enable), 
		  .serialOut(serialOut), 
		  .sync(sync));

endmodule
