// jrg170
// vxs182
module lab1
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
           output HEX0_DP,           // Error state decimal point
           output [ 6: 0 ] HEX1_D,
           output HEX1_DP,           // Blank
           output [ 6: 0 ] HEX2_D,
           output HEX2_DP,           // Blank
           output [ 6: 0 ] HEX3_D,
           output HEX3_DP,           // Clock
           //////////////////////// LED ////////////////////////
           output [ 9: 0 ] LEDG
       );

// =======================================================
// REG/WIRE declarations
// =======================================================

reg [24 : 0] counter;
reg clk3hz;
wire [2 : 0] leftSignal;
wire [2 : 0] rightSignal;

//=======================================================
// Input/Output assignments
//=======================================================

assign HEX0_D = 7'b1111111;
assign HEX1_D = 7'b1111111;
assign HEX2_D = 7'b1111111;
assign HEX3_D = 7'b1111111;
assign HEX1_DP = 1;
assign HEX2_DP = 1;
assign LEDG[3] = 0;
assign LEDG[6] = 0;
assign HEX3_DP = !clk3hz;

// =======================================================
// Structural coding
// =======================================================

Turn_Signal_Machine turnSignal(clk3hz, SW[1], SW[0], leftSignal, rightSignal, HEX0_DP);
Brake_Light_Machine brakeLight(clk3hz, !BUTTON[2], leftSignal, rightSignal, LEDG[9 : 7], LEDG[5 : 4], LEDG[2 : 0]);

// =======================================================
// Behavioral coding
// =======================================================

always @(posedge CLOCK_50) begin
	counter <= counter + 1;
	clk3hz <= counter[24];
end

endmodule
