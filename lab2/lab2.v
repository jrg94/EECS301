module lab2
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
wire countUp;                          // Connects the count up button to the math module
wire countDown;                        // Connects the count down button to the math module
wire reset;                            // Connects the reset button to the goal in math module
wire enable;                           // Connects the enable switch to the motor drive
wire [7 : 0] gain;                     // Connects the gain from the switches to the math module
wire signed [7 : 0] measuredSpeed;     // Connects measured speed from quadriture module to the math module
wire aOut, bOut;                       // Connects the motor feedback to the quadriture module
wire aIn, bIn;                         // Connects the motor input to the PWM module
wire signed [7 : 0] dutyCycle;         // Connects the duty cycle to the PWM module

//=======================================================
// Input/Output assignments
//=======================================================
// All unused inout port turn to tri-state
assign GPIO0_D = 32'hzzzzzzzz;
assign GPIO1_D = 32'hzzzzzzzz;

assign clk = CLOCK_50;                 // 50 MHz clock
assign countUp = ~BUTTON[0];           // Goal increase (active low)
assign countDown = ~BUTTON[1];         // Goal decrease (active low)
assign reset = ~BUTTON[2];             // Goal reset    (active low)
assign enable = SW[0];                 // Motor drive enable
assign gain = SW[9 : 2];               // Gain switches: 0 - 256
assign GPIO0_D[0] = aIn;               // Motor IN1 (AB16)  ***OUTPUT***
assign GPIO0_D[1] = bIn;               // Motor IN2 (AA16)  ***OUTPUT***
assign aOut = GPIO0_D[4];              // Motor OUT1 (AA14)
assign bOut = GPIO0_D[5];              // Motor OUT2 (AB14)

// =======================================================
// Structural coding
// =======================================================

assign GPIO0_D[2] = enable; // Drives the motor enable
assign GPIO0_D[3] = SW[1];

Quadriture quad(aOut, bOut, clk, measuredSpeed);                                    // Recieves feedback from the motor and calculates a speed
Math math(clk, countUp, countDown, reset, gain, measuredSpeed, dutyCycle);  // Produces a duty cycle from the feedback and the goal/gain inputs
PWM pwm(clk, dutyCycle, aIn, bIn);                                                  // Translates the duty cycle into a signal that gets fed into the motor

endmodule
