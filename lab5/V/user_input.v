// Handles all user input
// JRG170, VXS182
module user_input
	(
		input clk,
		input coord_select,
		input add, sub,
		output [10 : 0] write_addr,
		output reg [5 : 0] x_count, // Must count up to 60 to index horizontally
		output reg [4 : 0] y_count  // Must count up to 17 to index vertically
	);
	 
reg [20 : 0] counter; 

assign write_addr = x_count + (y_count * 6'd60);

// Handles how x_count and y_count are manipulated
always @(posedge clk) begin
	if (counter == 22'h1FFFFF) begin
		if (coord_select) begin
			y_count <= y_count;
			if (add && ~sub) begin												
				x_count <= x_count + 1'b1;
			end else if (sub && ~add) begin									
				x_count <= x_count - 1'b1;
			end else begin															
					x_count <= x_count;
			end
		end else begin
			x_count <= x_count;
			if (add && ~sub) begin															 
				y_count <= y_count + 1'b1;
			end else if (sub && ~add) begin
				y_count <= y_count - 1'b1;
			end else begin
				y_count <= y_count;
			end
		end 
	end else begin
		if (x_count > 59) begin
			x_count <= 0;
			y_count <= y_count;
		end else if (y_count > 16) begin
			x_count <= x_count;
			y_count <= 0;
		end else begin
			y_count <= y_count;
			x_count <= x_count;
		end
	end
end

// Will be edited later to handle one button press
always @(posedge clk) begin
	if (add || sub) begin
		counter <= counter + 1'b1;
	end else begin
		counter <= 1'b0;
	end
end
	
endmodule