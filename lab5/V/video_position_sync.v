// The timing module for the display
// JRG170, VXS182
module video_position_sync
       (
           input disp_clk,
           input en,
           output reg disp_hsync, disp_vsync,
           output reg valid_draw, v_blank,
           output reg [ 9: 0 ] h_pos, v_pos
       );
// Module header template
// Replace with implemented version to test functionality	

// Have two counters: one for vertical 'position' and one for horizontal 'position'
// Reset counters and pull all outputs low when disabled (en == 0)
// Horizontal must count to 525
// Vertical must count to 286

// Two synchronization signals go out to the display as required
// valid_draw is when h_pos and v_pos are indicating drawn pixels on the screen
// h_pos and v_pos should count y pixel and x pixel position when on the screen
// their values do not matter in the undrawn regions
// v_blank is to be held low for the entirety of the undrawn horizontal lines

parameter h_period = 524;
parameter v_period = 285;

always @(posedge disp_clk) begin
	if (en) begin
		// HANDLES h_pos: Cycles h_pos, Increments v_pos
		if (h_pos == h_period) begin
			v_pos <= v_pos + 1'b1;
			h_pos <= 0;
		end else begin
			h_pos <= h_pos + 1'b1;
		end
		
		// HANDLES disp_hsync: Triggers hsync
		if (h_pos >= 484 && h_pos <= h_period) begin  // Send h_sync low for the last 41 cycles
			disp_hsync <= 0;
		end else begin											 // Otherwise, send h_sync high
			disp_hsync <= 1;
		end
	
		// HANDLES v_pos & v_blank: Resets v_pos, Sets v_blank
		if (v_pos == v_period) begin
			v_pos <= 0;
			v_blank <= 0;
		end else if (v_pos == 0 || v_pos == 1 || v_pos >= 274) begin  // 2 + 272 + 2
			v_blank <= 0;
		end else begin
			v_blank <= 1;
		end
			
		
		// HANDLES disp_vsync: Triggers vsync
		if (v_pos >= 276 && v_pos <= v_period) begin		// Send v_sync low for the last 10 cycles
			disp_vsync <= 0;
		end else begin												// Otherwise, send v_sync high
			disp_vsync <= 1;
		end
		
		// HANDLES valid_draw
		if ((v_pos >= 2 && v_pos <= 273) && (h_pos >= 2 && h_pos <= 481)) begin // Hold valid_draw high in drawing regions
			valid_draw <= 1;	
		end else begin																				// Otherwise, hold it low
			valid_draw <= 0;
		end

	end else begin
		v_pos <= 0;
		h_pos <= 0;
		v_blank <= 0;
		valid_draw <= 0;
		disp_hsync <= 0;
		disp_vsync <= 0;
	end
	
end


endmodule
