// JRG170, VXS182
module lab3
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

wire clk;                              // Connects the clock to all modules
wire a, b;                             // Connects the motor feedback to the quadriture module
wire encoder_setting;						// Connects Switch 0 to the quadriture module
wire reset;										// Connects Button 0 to the quadriture module
wire enable;									// Connects Swith 1 to the DAC module
wire [31 : 0] frequency;               // Connects the frequency output of the quadriture module to the NCO module 
wire [11 : 0] amplitude;               // Connects the amplitude output of the quadriture module to the NCO module 
wire [31 : 0] nco_frequency;				// Connects the frequency generated by the NCO module to the shift register module 
wire serialIntoDAC;                    // Connects the serial output of the shift register module to the DAC module (AA13)
wire sync;										// Connects the sync signal from the shift register module to the DAC module (AB10)
wire sclk;										// Connects the sample clk signal to the DAC module (AB13)
wire aIn, bIn; 								// Connects power to the motor inputs
wire out_valid;								// Connects an LED for DAC debugging
wire pulse;										// Connects pulse to NCO

//=======================================================
// Input/Output assignments
//=======================================================
// All inout port turn to tri-state
assign GPIO0_D = 32'hzzzzzzzz;
assign GPIO1_D = 32'hzzzzzzzz;

assign clk = CLOCK_50;              // Attaches the 50MHz clock to the clk wire
assign a = GPIO0_D[4];              // Attaches Motor OUT1 (AA14) to the a wire
assign b = GPIO0_D[5];              // Attaches Motor OUT2 (AB14) to the b wire
assign encoder_setting = SW[0];     // Attaches Switch 0 to the encoder_setting wire
assign reset = ~BUTTON[0];				// Attaches Button 0 to the reset wire
assign enable = SW[1];					// Attaches Switch 0 to the enable wire

/** DAC INPUTS **/
assign GPIO0_D[6] = clk;            // Attaches the clock to the sclk input                              
assign GPIO0_D[7] = serialIntoDAC;  // Attaches the serial output from the shift register module to the DAC 
assign GPIO0_D[8] = sync;				// Attaches the sync command from the shift register module to the DAC (ACTIVE LOW)
assign GPIO0_D[9] = 0;              // Attaches the LDAC pin to 0 (ACTIVE LOW)
assign GPIO0_D[10] = 0;					// Attaches the CLR pin to 0 (ACTIVE LOW)
/** DAC INPUTS **/

assign GPIO0_D[0] = aIn;            // Motor IN1 (AB16)  ***OUTPUT***
assign GPIO0_D[1] = bIn;            // Motor IN2 (AA16)  ***OUTPUT***
assign aIn = SW[7];
assign bIn = SW[6];     

// assign LEDG[0] = out_valid;      // Debugging NCO output

// =======================================================
// Structural coding
// =======================================================

Quadriture quad(.A(a), .B(b), .clk(clk), .encoder_setting(encoder_setting), .reset(reset), .frequency(frequency), .amplitude(amplitude));
NCO_Manager nco(.phi_inc_i(frequency), .clk(clk), .clken(pulse), .amplitude(amplitude), .fsin_o(nco_frequency), .out_valid(out_valid));
Shift_Manager shiftReg(.clk(clk), .parallelIn(nco_frequency), .pulse(pulse), .enable(enable), .serialOut(serialIntoDAC), .sync(sync));
Sample_Clock sampleClock(.clk(clk), .sclk(sclk), .pulse(pulse));

endmodule
