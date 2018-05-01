module fireball_sprite (input 					frame_clk,
															Reset,
															player_or_npc, // 1: player, 0: npc
															
								input [9:0]				DrawX,
															DrawY,
															proj_x_curr,
															proj_y_curr,

								input						fire_active,

								output logic [9:0]	sprite_size_x,
															sprite_size_y,
								
								output logic 			fire_pixel_on,
								
								output logic [23:0]	fire_pixel);

	parameter bit [0:3][23:0] palette = {24'hff0000,
													24'he8655d,
													24'he8790c,
													24'hffdd00};

	// ROM definition, 11*16
	parameter [0:175][2:0] mem = {
        3'h0, 3'h0, 3'h0, 3'h1, 3'h1, 3'h1, 3'h1, 3'h1, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0,
        3'h0, 3'h0, 3'h1, 3'h2, 3'h2, 3'h2, 3'h2, 3'h2, 3'h1, 3'h1, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0,
        3'h0, 3'h1, 3'h2, 3'h3, 3'h3, 3'h3, 3'h3, 3'h3, 3'h2, 3'h2, 3'h1, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0,
        3'h1, 3'h2, 3'h3, 3'h3, 3'h4, 3'h4, 3'h3, 3'h3, 3'h2, 3'h2, 3'h1, 3'h1, 3'h0, 3'h0, 3'h0, 3'h0,
        3'h1, 3'h2, 3'h3, 3'h3, 3'h4, 3'h4, 3'h4, 3'h4, 3'h3, 3'h3, 3'h2, 3'h2, 3'h1, 3'h1, 3'h0, 3'h0,
        3'h1, 3'h2, 3'h3, 3'h3, 3'h4, 3'h4, 3'h4, 3'h4, 3'h4, 3'h4, 3'h4, 3'h4, 3'h4, 3'h3, 3'h2, 3'h1,
        3'h1, 3'h2, 3'h3, 3'h3, 3'h4, 3'h4, 3'h4, 3'h4, 3'h3, 3'h3, 3'h2, 3'h2, 3'h1, 3'h1, 3'h0, 3'h0,
        3'h1, 3'h2, 3'h3, 3'h3, 3'h4, 3'h4, 3'h3, 3'h3, 3'h2, 3'h2, 3'h1, 3'h1, 3'h0, 3'h0, 3'h0, 3'h0,
        3'h0, 3'h1, 3'h2, 3'h3, 3'h3, 3'h3, 3'h3, 3'h3, 3'h2, 3'h2, 3'h1, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0,
        3'h0, 3'h0, 3'h1, 3'h2, 3'h2, 3'h2, 3'h2, 3'h2, 3'h1, 3'h1, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0,
        3'h0, 3'h0, 3'h0, 3'h1, 3'h1, 3'h1, 3'h1, 3'h1, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0, 3'h0,
        };
		  
	parameter [9:0] sprite_x_size = 16;
	parameter [9:0] sprite_y_size = 11;
	
	assign sprite_size_x = sprite_x_size;
	assign sprite_size_y = sprite_y_size;
	
	logic [7:0] fire_address;
	logic [4:0] LUT_idx;
	logic [3:0]	offset;
	
	fireball_animation_control(.Clk(frame_Clk),
										.Reset(Reset),
										.is_active(fire_active),
										.idx_offset(offset));
	
	always_comb
	begin
		if(player_or_npc)
			fire_address = (DrawY - proj_y_curr)*sprite_size_x + (DrawX - proj_x_curr);
		else
			fire_address = (DrawY - proj_y_curr)*sprite_size_x + (10'd15 - (DrawX - proj_x_curr));
		
		// retrieve index for color palette
		LUT_idx = mem[fire_address];
		
		// white or non-white
		if(LUT_idx == 5'd0)
			fire_pixel_on = 1'b0;
		else
			fire_pixel_on = 1'b1;
		
		
		LUT_idx = LUT_idx + (~1'd1+1'd1);
		// ugly animation
		// produce color
		if(offset == 10'd1)
		begin
			if(LUT_idx == 5'd0)
				LUT_idx = 5'd1;
			else if(LUT_idx == 5'd1)
				LUT_idx = 5'd2;
			else if(LUT_idx == 5'd2)
				LUT_idx = 5'd3;
			else if(LUT_idx == 5'd3)
				LUT_idx = 5'd0;
		end
		else if(offset == 10'd2)
		begin
			if(LUT_idx == 5'd0)
				LUT_idx = 5'd2;
			else if(LUT_idx == 5'd1)
				LUT_idx = 5'd3;
			else if(LUT_idx == 5'd2)
				LUT_idx = 5'd0;
			else if(LUT_idx == 5'd3)
				LUT_idx = 5'd1;
		end
		else if(offset == 10'd3)
		begin
			if(LUT_idx == 5'd0)
				LUT_idx = 5'd3;
			else if(LUT_idx == 5'd1)
				LUT_idx = 5'd0;
			else if(LUT_idx == 5'd2)
				LUT_idx = 5'd1;
			else if(LUT_idx == 5'd3)
				LUT_idx = 5'd2;
		end
		
		fire_pixel = palette[LUT_idx];
	end

endmodule
