// JRG170, VXS182

/**
 * Determines which bank we want to access based on some button inputs
 */
module bank_settings
	(
		input clk,
		input bank_one,		// Low Pass
		input bank_two,		// Band Pass
		input bank_three,		// High Pass
		output reg [1 : 0] bank_number
	);
	
always @(posedge clk) begin
	if (bank_one && ~bank_two && ~bank_three) begin
		bank_number <= 2'b01;
	end else if (bank_two && ~bank_one && ~bank_three) begin
		bank_number <= 2'b10;
	end else if (bank_three && ~bank_one && ~bank_two) begin
		bank_number <= 2'b11;
	end else begin
		bank_number <= 2'b00;
	end
end
	
endmodule
	