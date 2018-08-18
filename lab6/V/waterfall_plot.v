// JRG170, VXS182

/**
 * Does that actual displaying of data
 */
module waterfall_plot 
	(
		input clk, en,
      input valid_region, v_blank,
		input [9 : 0] x_pos, y_pos,
		input [23 : 0] color,
      output reg [ 7: 0 ] value_red, value_green, value_blue,
		output reg control
	);
	
always @(posedge clk) begin
	if (valid_region && en) begin
		if (x_pos > 100 && x_pos < 140) begin
			value_red <= color[7 : 0];
			value_green <= color[15 : 8];
			value_blue <= color[23 : 16];
		end else if (x_pos > 340 && x_pos < 380) begin
			value_red <= color[7 : 0];
			value_green <= color[15 : 8];
			value_blue <= color[23 : 16];
		end else begin
			value_red <= 8'd0;
			value_green <= 8'd0;
			value_blue <= 8'd0;
		end
	end else begin
		value_red <= 8'd0;
		value_green <= 8'd0;
		value_blue <= 8'd0;
	end
	
	if (x_pos < 240) begin
		control <= 1;
	end else begin
		control <= 0;
	end
end	
	
endmodule