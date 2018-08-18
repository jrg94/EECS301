// jrg170
// vxs182
module Turn_Signal_Machine
		(
		
			input CLOCK,
			input LEFT,
			input RIGHT,
			
			output reg [ 2 : 0 ] L_SIGNAL,
			output reg [ 2 : 0 ] R_SIGNAL,
			output reg ERROR
		
		);
	
	
// States //
parameter idle = 0, err = 1, left1A = 2, left1B = 3, left1C = 4, left2A = 5, left2B = 6, left2C = 7, 
			 left3A = 8, left3B = 9, left3C = 10, right1A = 11, right1B = 12, right1C = 13, right2A = 14,
			 right2B = 15, right2C = 16, right3A = 17, right3B = 18, right3C = 19;

// Registers
reg [ 4: 0 ] state, next_state;

// Next state combinational logic

always @( * ) begin
	case (state)
		idle: // The initial state
			if (LEFT == 1 && RIGHT != 1) begin
				next_state <= left1A;
			end
			else if (RIGHT == 1 && LEFT != 1) begin
				next_state <= right1A;
			end
			else if (RIGHT == 1 && LEFT == 1) begin
				next_state <= err;
			end
			else begin
				next_state <= idle;
			end
		err: // The error state
			if (LEFT == 0 || RIGHT == 0) begin
				next_state <= idle;
			end
			else begin 
				next_state <= err;
			end
		left1A:
			next_state <= left1B;
		left1B:
			next_state <= left1C;
		left1C: // The first stage of the left turn signal cycle
			if (LEFT == 1 && RIGHT == 0) begin
				next_state <= left2A;
			end
			else if (LEFT == 1 && RIGHT == 1) begin
				next_state <= err;
			end
			else begin
				next_state <= idle;
			end
		left2A:
			next_state <= left2B;
		left2B:
			next_state <= left2C;
		left2C: // The second stage of the left turn signal cycle
			if (LEFT == 0) begin
				next_state <= idle;
			end
			else if (LEFT == 1 && RIGHT == 1) begin
				next_state <= err;
			end
			else begin
				next_state <= left3A;
			end
		left3A:
			next_state <= left3B;
		left3B:
			next_state <= left3C;
		left3C: // The final stage of the left turn signal cycle
			if (LEFT == 1 && RIGHT == 1) begin
				next_state <= err;
			end
			else begin
				next_state <= idle;
			end
		right1A:
			next_state <= right1B;
		right1B:
			next_state <= right1C;
		right1C: // The first stage of the right turn signal cycle
			if (RIGHT == 1 && LEFT != 1) begin
				next_state <= right2A;
			end
			else if (LEFT == 1 && RIGHT == 1) begin
				next_state <= err;
			end
			else begin
				next_state <= idle;
			end
		right2A:
			next_state <= right2B;
		right2B:
			next_state <= right2C;
		right2C: // The second stage of the right turn signal cycle
			if (RIGHT == 1 && LEFT != 1) begin
				next_state <= right3A;
			end
			else if (LEFT == 1 && RIGHT == 1) begin
				next_state <= err;
			end
			else begin
				next_state <= idle;
			end
		right3A:
			next_state <= right3B;
		right3B:
			next_state <= right3C;
		right3C: // The last stage of the right turn signal cycle
				if (LEFT == 1 && RIGHT == 1) begin
					next_state <= err;
				end
				else begin
					next_state <= idle;
				end
	endcase
end

// Output combinational logic

always @ ( * ) begin
	case (state)
		idle: begin
			L_SIGNAL <= 3'b000;
			R_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		err: begin
			L_SIGNAL <= 3'b000;
			R_SIGNAL <= 3'b000;
			ERROR <= 0;
		end
		left1A: begin
			L_SIGNAL <= 3'b001;
			R_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		left1B: begin
			L_SIGNAL <= 3'b001;
			R_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		left1C: begin
			L_SIGNAL <= 3'b001;
			R_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		left2A: begin
			L_SIGNAL <= 3'b011;
			R_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		left2B: begin
			L_SIGNAL <= 3'b011;
			R_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		left2C: begin
			L_SIGNAL <= 3'b011;
			R_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		left3A: begin
			L_SIGNAL <= 3'b111;
			R_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		left3B: begin
			L_SIGNAL <= 3'b111;
			R_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		left3C: begin
			L_SIGNAL <= 3'b111;
			R_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		right1A: begin
			R_SIGNAL <= 3'b100;
			L_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		right1B: begin
			R_SIGNAL <= 3'b100;
			L_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		right1C: begin
			R_SIGNAL <= 3'b100;
			L_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		right2A: begin
			R_SIGNAL <= 3'b110;
			L_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		right2B: begin
			R_SIGNAL <= 3'b110;
			L_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		right2C: begin
			R_SIGNAL <= 3'b110;
			L_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		right3A: begin
			R_SIGNAL <= 3'b111;
			L_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		right3B: begin
			R_SIGNAL <= 3'b111;
			L_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
		right3C: begin
			R_SIGNAL <= 3'b111;
			L_SIGNAL <= 3'b000;
			ERROR <= 1;
		end
	endcase
end

// State transition logic

always @(posedge CLOCK) begin
	state <= next_state;
end

endmodule