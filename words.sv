module word_FIGHT(input [9:0] 			DrawX,
													DrawY,
						input						active,
											
						output logic [9:0] 	start_x, // start position
													start_y,	// start position
													
													n,
						output logic 			is_word
						);

	parameter [9:0] word_x_start = 296;
	parameter [9:0] word_y_start = 232;
	parameter [9:0] word_size_x = 48; // FIGHT! = 6chars*8width
	parameter [9:0] font_size_y = 16;
	
	assign start_x = word_x_start;
	assign start_y = word_y_start;
	
	always_comb
	begin
		if(DrawX-word_x_start < 9'd8)
			n = 9'h0f; // F
		else if(DrawX-word_x_start < 9'd16)
			n = 9'h12; // I
		else if(DrawX-word_x_start < 9'd24)
			n = 9'h10; // G
		else if(DrawX-word_x_start < 9'd32)
			n = 9'h11; // H
		else if(DrawX-word_x_start < 9'd40)
			n = 9'h1d; // T
		else
			n = 9'h3f; // !
	end
	
	always_comb
	begin
		// if the current pixel is within the box
		if(DrawX >= word_x_start && DrawX < word_x_start + word_size_x &&
			DrawY >= word_y_start && DrawY < word_y_start + font_size_y &&
			active == 1'b1)
			is_word = 1'b1;
		else
			is_word = 1'b0;
	end
endmodule

module word_DEFEAT(input [9:0] 			DrawX,
													DrawY,
						input						active,					
						
						output logic [9:0] 	start_x, // start position
													start_y,	// start position
													
													n,
						output logic 			is_word
						);
						
	parameter [9:0] word_x_start = 292;
	parameter [9:0] word_y_start = 232;
	parameter [9:0] word_size_x = 56; // DEFEAT! = 7chars*8width
	parameter [9:0] font_size_y = 16;
	
	assign start_x = word_x_start;
	assign start_y = word_y_start;
	
	always_comb
	begin
		if(DrawX-word_x_start < 9'd8)
			n = 9'h0d; // D
		else if(DrawX-word_x_start < 9'd16)
			n = 9'h0e; // E
		else if(DrawX-word_x_start < 9'd24)
			n = 9'h0f; // F
		else if(DrawX-word_x_start < 9'd32)
			n = 9'h0e; // E
		else if(DrawX-word_x_start < 9'd40)
			n = 9'h0a; // A
		else if(DrawX-word_x_start < 9'd48)
			n = 9'h1d; // T
		else
			n = 9'h3f; // !
	end
	
	always_comb
	begin
		// if the current pixel is within the box
		if(DrawX >= word_x_start && DrawX < word_x_start + word_size_x &&
			DrawY >= word_y_start && DrawY < word_y_start + font_size_y &&
			active == 1'b1)
			is_word = 1'b1;
		else
			is_word = 1'b0;
	end
endmodule

module word_VICTORY(input [9:0] 			DrawX,
													DrawY,
						input						active,
											
						output logic [9:0] 	start_x, // start position
													start_y,	// start position
													
													n,
						output logic 			is_word
						);
						
	parameter [9:0] word_x_start = 288;
	parameter [9:0] word_y_start = 232;
	parameter [9:0] word_size_x = 64; // VICTORY! = 7chars*8width
	parameter [9:0] font_size_y = 16;
	
	assign start_x = word_x_start;
	assign start_y = word_y_start;
	
	always_comb
	begin
		if(DrawX-word_x_start < 9'd8)
			n = 9'h1f; // V
		else if(DrawX-word_x_start < 9'd16)
			n = 9'h12; // I
		else if(DrawX-word_x_start < 9'd24)
			n = 9'h0c; // C
		else if(DrawX-word_x_start < 9'd32)
			n = 9'h1d; // T
		else if(DrawX-word_x_start < 9'd40)
			n = 9'h18; // O
		else if(DrawX-word_x_start < 9'd48)
			n = 9'h1b; // R
		else if(DrawX-word_x_start < 9'd56)
			n = 9'h22; // Y
		else
			n = 9'h3f; // !
	end
	
	always_comb
	begin
		// if the current pixel is within the box
		if(DrawX >= word_x_start && DrawX < word_x_start + word_size_x &&
			DrawY >= word_y_start && DrawY < word_y_start + font_size_y &&
			active == 1'b1)
			is_word = 1'b1;
		else
			is_word = 1'b0;
	end
endmodule

module word_player(input [9:0] 			DrawX,
													DrawY,
						input						active,
											
						output logic [9:0] 	start_x, // start position
													start_y,	// start position
													
													n,
						output logic 			is_word
						);
						
	parameter [9:0] word_x_start = 10;
	parameter [9:0] word_y_start = 10;
	parameter [9:0] word_size_x = 48;
	parameter [9:0] font_size_y = 16;
	
	assign start_x = word_x_start;
	assign start_y = word_y_start;
	
	always_comb
	begin
		if(DrawX-word_x_start < 9'd8)
			n = 9'h19; // p
		else if(DrawX-word_x_start < 9'd16)
			n = 9'h15; // l
		else if(DrawX-word_x_start < 9'd24)
			n = 9'h0a; // a
		else if(DrawX-word_x_start < 9'd32)
			n = 9'h22; // y
		else if(DrawX-word_x_start < 9'd40)
			n = 9'h0e; // e
		else
			n = 9'h1b; // r
	end
	
	always_comb
	begin
		// if the current pixel is within the box
		if(DrawX >= word_x_start && DrawX < word_x_start + word_size_x &&
			DrawY >= word_y_start && DrawY < word_y_start + font_size_y &&
			active == 1'b1)
			is_word = 1'b1;
		else
			is_word = 1'b0;
	end
endmodule

module word_npc(input [9:0] 			DrawX,
													DrawY,
						input						active,
											
						output logic [9:0] 	start_x, // start position
													start_y,	// start position
													
													n,
						output logic 			is_word
						);
						
	parameter [9:0] word_x_start = 538;
	parameter [9:0] word_y_start = 10;
	parameter [9:0] word_size_x = 24;
	parameter [9:0] font_size_y = 16;
	
	assign start_x = word_x_start;
	assign start_y = word_y_start;
	
	always_comb
	begin
		if(DrawX-word_x_start < 9'd8)
			n = 9'h17; // n
		else if(DrawX-word_x_start < 9'd16)
			n = 9'h19; // p
		else
			n = 9'h0c; // c
	end
	
	always_comb
	begin
		// if the current pixel is within the box
		if(DrawX >= word_x_start && DrawX < word_x_start + word_size_x &&
			DrawY >= word_y_start && DrawY < word_y_start + font_size_y &&
			active == 1'b1)
			is_word = 1'b1;
		else
			is_word = 1'b0;
	end
endmodule
