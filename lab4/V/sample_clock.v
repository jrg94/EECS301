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
	
reg [7 : 0] counter;

always @(posedge clk) begin
	if(counter == 8'd250) begin
		counter <= 8'd0;
		pulse <= 1;
	end else begin
		counter <= counter + 8'd1;
		pulse <= 0;
	end
end 
	
endmodule