// JRG170, VXS182
module lab5
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

wire clk;								// 9MHz clock signal
wire enable;							// SW[1] enable signal
wire disp_en;							// Enables the display signal
wire h_sync;							// Horizontal sync signal
wire v_sync;							// Vertical sync signal
wire valid_draw;						// The valid draw signal
wire v_blank;							// Vertical blank region signal
wire pll_lock;							// 9Mhz clock lock signal
wire coord_select;					// SW[0] coordinate signal
wire add, sub;							// BUTTON[1:0] motion signals
wire write;								// BUTTON[2] write enable signal
wire [4 : 0] y_index;				// 5-bit y-index signal
wire [5 : 0] x_index;				// 6-bit x-index signal
wire [6 : 0] char_select;			// SW[9:3] character select signal
wire [6 : 0] ram_read;				// 7-bit RAM read output
wire [7 : 0] red;						// 8-bit red signal
wire [7 : 0] green;					// 8-bit green signal
wire [7 : 0] blue;					// 8-bit blue signal
wire [7 : 0] data;					// 8-bit ROM read signal
wire [9 : 0] offset;					// 10-bit x-position offset signal
wire [9 : 0] h_pos;					// 10-bit x-position signal
wire [9 : 0] v_pos;					// 10-bit y-position signal
wire [10 : 0] write_addr;			// 11-bit RAM write address signal
wire [10 : 0] read_addr;			// 11-bit RAM write address signal

//=======================================================
// Input/Output assignments
//=======================================================
// All unused inout port turn to tri-state
assign GPIO0_D = 32'hzzzzzzzz;
assign GPIO1_D = 32'hzzzzzzzz;

// User Input Signals
assign coord_select = SW[0];
assign enable = SW[1];
assign char_select = SW[9 : 3];
assign add = ~BUTTON[0];
assign sub = ~BUTTON[1];
assign write = ~BUTTON[2];

// Display Signals
assign GPIO1_D[ 27: 0 ] = { v_sync, h_sync, disp_en, clk, blue, green, red };
assign disp_en = pll_lock; // Enable the display just after PLL has locked

// =======================================================
// Structural coding
// =======================================================

// Takes the 50MHz clock and produces a 9MHz clock
clock_megafunction clock_func(.inclk0(CLOCK_50),
										.c0(clk),
										.locked(pll_lock));

// Takes 9MHz clock, 7 switches, and 3 buttons to 
// produce a data from ROM										
user_input ui(.clk(clk),
				  .coord_select(coord_select),
				  .add(add),
				  .sub(sub),
				  .x_count(x_index),
				  .y_count(y_index),
				  .write_addr(write_addr));

// Takes two 9MHz clocks and a switch to read/write
// the RAM				  
ram_dual rd(.data(char_select),			// 7 bits
				.read_addr(read_addr),					 
				.write_addr(write_addr),	
				.we(write),						// Write enable signal
				.read_clock(clk),
				.write_clock(clk),
				.q(ram_read));

// Produces the RAMs read address from v_pos and h_pos
// Extracts the character from ROM
rom_manager rm(.clk(clk),
					.x_pos(offset),
					.y_pos(v_pos),
					.char(ram_read),
					.read_addr(read_addr),
					.data(data));				// The 8 bits of character data from ROM			

// Handles all timing for the display					
video_position_sync vps(.disp_clk(clk),
								.en(pll_lock),
								.disp_hsync(h_sync),
								.disp_vsync(v_sync),
								.valid_draw(valid_draw),
								.v_blank(v_blank),
								.h_pos(offset));

// Handles the display
disp_highlight dh(.clk(clk),
						.en(enable),
						.x_pos(h_pos),
						.y_pos(v_pos),
						.valid_region(valid_draw),
						.v_blank(v_blank),
						.x_index(x_index),
						.y_index(y_index),
						.char(data),
						.value_red(red),
						.value_green(green),
						.value_blue(blue));				  
endmodule
