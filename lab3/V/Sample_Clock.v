// JRG170, VXS182

/**
 * Generates a 50KHz clock from the 50MHz clock signal
 */
module Sample_Clock
	(
		input clk,             // 50 MHz input clock
		output reg sclk,        // 50 KHz output clock
		output reg pulse
	);
	
reg [9 : 0] counter;

always @(posedge clk) begin
	if(counter == 10'd625) begin   // THIS SHOULDN"T WORK...
		counter <= 10'd0;
		sclk <= ~sclk;
		if (sclk == 0) begin
			pulse <= 0;
		end else begin
			pulse <= 1;
		end
	end else begin
		counter <= counter + 10'd1;
		pulse <= 0;
	end
end 


endmodule	