module char_frameRAM(input [11:0]				Player_address,
															NPC_address,

							output logic [9:0]		sprite_size_x,
															
							output logic				player_pixel_on,
															npc_pixel_on,
							output logic [23:0] 		Player_pixel,
															NPC_pixel);

	parameter bit [0:14][23:0] palette = {24'hffffff, // white should be ignored
																24'hfba500,
																24'h1e3791,
																24'h3a2313,
																24'h664911,
																24'ha28446,
																24'h6e0559,
																24'h6d6d6d,
																24'h3f4044,
																24'he08f7a,
																24'h3c52a8,
																24'h536dc4,
																24'h850305,
																24'h86652f,
																24'he48322};
	
	logic [3:0] mem [0:2859]; // 44*65
	
	initial
	begin
		$readmemh("sprite_bytes/char.txt", mem);
	end
	
	parameter [9:0] sprite_x_size = 41;
	parameter [9:0] sprite_y_size = 65;
	
	assign sprite_size_x = sprite_x_size;
	
	logic [3:0] Player_LUT_idx, NPC_LUT_idx;
	
	always_comb
	begin
		// retrieve index for color palette
		Player_LUT_idx = mem[Player_address];
		// different colors for players
		if(NPC_LUT_idx == 4'd2) // robe
			NPC_LUT_idx = 4'd12;
		else if(NPC_LUT_idx == 4'd12) // medalion
			NPC_LUT_idx = 4'd2;
		else
			NPC_LUT_idx = mem[NPC_address];
		
		// white or non-white
		if(Player_LUT_idx == 4'd1)
			player_pixel_on = 1'b0;
		else
			player_pixel_on = 1'b1;
		
		if(NPC_LUT_idx == 4'd1)
			npc_pixel_on = 1'b0;
		else
			npc_pixel_on = 1'b1;
		
		// produce color
		Player_pixel = palette[Player_LUT_idx];
		NPC_pixel = palette[NPC_LUT_idx];
	end
	
endmodule
