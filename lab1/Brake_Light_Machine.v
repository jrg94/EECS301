// jrg170
// vxs182
module Brake_Light_Machine
		(
		
			input CLOCK,
			input BRAKE,
			input [2 : 0] L_SIGNAL,
			input [2 : 0] R_SIGNAL,
			
			output reg [2 : 0] L_LIGHTS,
			output reg [1 : 0] C_LIGHTS,
			output reg [2 : 0] R_LIGHTS
		
		);

// States
parameter idle = 0, breakInitial = 1, break1 = 2, break2 = 3;

// Registers
reg [2 : 0] state, next_state;
reg [1 : 0] counter;
reg brake_active;		
		
// Next state combinational logic

always @( * ) begin
	case (state)
		idle:
			if (BRAKE == 1) begin
				next_state <= breakInitial;
				brake_active <= 1;
			end
			else begin
				next_state <= idle;
				brake_active <= 0;
			end
		breakInitial:
			if (BRAKE == 1) begin
				next_state <= breakInitial;
				brake_active <= 1;
			end
			else begin
				next_state <= break1;
				brake_active <= 1;
			end
		break1:
			if (BRAKE == 1) begin
				next_state <= breakInitial;
				brake_active <= 1;
			end
			else begin
				next_state <= break2;
				brake_active <= 1;
			end
		break2:
			if (BRAKE == 1) begin
				next_state <= breakInitial;
				brake_active <= 1;
			end
			else begin
				next_state <= idle;
				brake_active <= 0;
			end
	endcase
end

// Output combinational logic

always @( * ) begin
	if (brake_active == 1) begin
		integer i;
		for (i = 2; i >= 0; i = i - 1) begin
          L_LIGHTS[i] <= !L_SIGNAL[i];
			 R_LIGHTS[i] <= !R_SIGNAL[i];
		end
		C_LIGHTS <= 2'b11;
	end
	else begin
		L_LIGHTS <= L_SIGNAL;
		C_LIGHTS <= 2'b00;
		R_LIGHTS <= R_SIGNAL;
	end
end

// State transition logic

always @(posedge CLOCK) begin
	state <= next_state;
end		
		
endmodule