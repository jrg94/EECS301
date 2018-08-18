// JRG170, VXS182

/**
 * The sample clock module generates an
 * 80ksps pulse
 */
module sample_clock
	(
		input clk,
		output reg pulse
	);
	
reg [8 : 0] counter;

always @(posedge clk) begin
	if(counter == 9'd400) begin
		counter <= 9'd0;
		pulse <= 1;
	end else begin
		counter <= counter + 9'd1;
		pulse <= 0;
	end
end 
	
endmodule