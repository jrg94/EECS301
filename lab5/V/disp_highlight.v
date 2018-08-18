// Does that actual displaying of data
// JRG170, VXS182
module disp_highlight 
	(
		input clk, en,
      input valid_region, v_blank,
		input [5 : 0] x_index,
		input [4 : 0] y_index,
		input [7 : 0] char,
      output reg [ 7: 0 ] value_red, value_green, value_blue,
		output reg [9 : 0] x_pos, y_pos
	);
	
reg [7 : 0] flippedChar;

always @(posedge clk) begin
	flippedChar = {char[0], char[1], char[2], char[3], char[4], char[5], char[6], char[7]};
end
	
always @(posedge clk) begin
	if ( valid_region && en ) begin
		if (x_pos[8 : 3] == x_index && y_pos[8 : 4] == y_index) begin	// Shift by 3 = /8, Shift by 4 = /16 HIGHLIGHT REGION
			if (flippedChar[x_pos[2 : 0]] == 0) begin
				value_red <= 8'b11111111;
				value_green <= 8'b11111111;
				value_blue <= 8'b11111111;
			end else begin
				value_red <= 1'b0;
				value_green <= 1'b0;
				value_blue <= 1'b0;
			end
		end else begin																	// REGULAR REGION
			if (flippedChar[x_pos[2 : 0]] == 0) begin
				value_red <= 1'b0;
				value_green <= 1'b0;
				value_blue <= 1'b0;
			end else begin
				value_red <= 8'b11111111;
				value_green <= 8'b11111111;
				value_blue <= 8'b11111111;
			end
		end
    end
    else begin
        value_red <= 1'b0;
        value_green <= 1'b0;
        value_blue <= 1'b0;
    end
end

always @(posedge clk) begin
	if (valid_region) begin
		if (x_pos >= 0 && x_pos < 479) begin 
			x_pos <= x_pos + 1'b1;
			y_pos <= y_pos;
		end else if (x_pos == 479 && y_pos < 271) begin
			y_pos <= y_pos + 1'b1;
			x_pos <= 0;
		end else begin
			y_pos <= 0;
			x_pos <= 0;
		end
	end else begin
		x_pos <= x_pos;
		y_pos <= y_pos;
	end
end

			
	
	
endmodule