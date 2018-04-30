module char_frameRAM(input [9:0] 				DrawX,
															DrawY,
															sprite_x_start,
															sprite_y_start,

							output logic				pixel_on,
							output logic [23:0] 		data_out);

	parameter bit [0:14][23:0] palette = {24'hffffff,
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
												24'he48322}; // white should be ignored
	
	logic [3:0] mem [0:2859]; // 44*65
	
	initial
	begin
		$readmemh("sprite_bytes/char.txt", mem);
	end
	
	parameter [9:0] sprite_x_size = 41;
	parameter [9:0] sprite_y_size = 65;
	
	logic [11:0] address;
	logic [3:0] LUT_idx;
	
	assign address = (DrawY - sprite_y_start)*sprite_x_size + (DrawX - sprite_x_start);
	
	
	always_comb
	begin
		LUT_idx = mem[address];
		if(LUT_idx == 4'h0)
				pixel_on = 1'b0;
		else
		pixel_on = 1'b1;
		data_out = palette[LUT_idx];
	end
	
endmodule
