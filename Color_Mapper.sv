//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper (	input					Clk,
								input             is_player,            // Whether current pixel belongs to ball 
														is_npc,
														is_proj,
														// stage
														start_l,
														battle_l,
														win_l,
														lose_l,
														
								input					player_pixel_on,
								input [23:0]		player_pixel,
														
																					//   or background (computed in ball.sv)
								input        [9:0] DrawX, DrawY,       // Current pixel coordinates
								output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
	
	logic [7:0] Red, Green, Blue;
	// Output colors to VGA
	assign VGA_R = Red;
	assign VGA_G = Green;
	assign VGA_B = Blue;

	// font data
	logic [9:0] font_addr, n; // addressing font_rom
	logic [7:0] font_bitmap; // data from rom
	
	logic [9:0] FONT_y_start;
	logic [9:0] FIGHT_x_start, FIGHT_y_start, FIGHT_n;
	logic [9:0] DEFEAT_x_start, DEFEAT_y_start, DEFEAT_n;
	logic [9:0] VICTORY_x_start, VICTORY_y_start, VICTORY_n;
	logic is_FIGHT, is_DEFEAT, is_VICTORY;
	
	font_rom (.addr(font_addr),
				.data(font_bitmap)
				);
				
	logic [23:0] backgroundRAM_data;
	background_frameRAM(.DrawX(DrawX),
								.DrawY(DrawY),
								.Clk(Clk),
								.data_out(backgroundRAM_data)
								);
	
	// Assign color based on is_ball signal
	always_comb
	begin
		// assigning character logic
		if(is_FIGHT == 1'b1)
		begin
			FONT_y_start = FIGHT_y_start;
			n = FIGHT_n;
		end
		else if(is_DEFEAT == 1'b1)
		begin
			FONT_y_start = DEFEAT_y_start;
			n = DEFEAT_n;
		end
		else if(is_VICTORY == 1'b1)
		begin
			FONT_y_start = VICTORY_y_start;
			n = VICTORY_n;
		end
		else
		begin
			FONT_y_start = 0;
			n = 10'h0;
		end
		/* --------------------------------------------------------------------------- */
		font_addr = (DrawY - FONT_y_start + 16*n); // accessing font ROM
		if (start_l)
		begin
			// Text
			if((is_FIGHT == 1'b1) && (font_bitmap[7 - DrawX - FIGHT_x_start] == 1'b1))
			begin
				Red = 8'hff;
				Green = 8'h00;
				Blue = 8'h00;
			end
			else
			begin
				// Background
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
			end
		end // end start_l
		/* --------------------------------------------------------------------------- */
		else if(win_l)
		begin
			// Text
			if((is_VICTORY == 1'b1) && (font_bitmap[7 - DrawX - VICTORY_x_start] == 1'b1))
			begin
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
			end
			else
			begin
				// blood red
				Red = 8'h9C;
				Green = 8'h1D;
				Blue = 8'h08;
			end
		end // end win_l
		/* --------------------------------------------------------------------------- */
		else if(lose_l)
		begin
			// Text
			if((is_DEFEAT == 1'b1) && (font_bitmap[7 - DrawX - DEFEAT_x_start] == 1'b1))
			begin
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
			end
			else
			begin
				// dark purple
				Red = 8'h57;
				Green = 8'h00;
				Blue = 8'h7F;
			end
		end // end lose_l
		/* --------------------------------------------------------------------------- */
		else //if(game_l)
		begin
			// characters
			if (is_player == 1'b1 && player_pixel_on == 1'b1) 
			begin
				Red = player_pixel[23:16];
				Green = player_pixel[15:8];
				Blue = player_pixel[7:0];
			end
			else if (is_npc == 1'b1)
			begin
				// Black ball
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
			end
			else if (is_proj == 1'b1)
			begin
				Red = 8'hff;
				Green = 8'h00;
				Blue = 8'h00;
			end
			// end characters
			
			else // background
			begin
				// Background with nice color gradient
				Red = backgroundRAM_data[23:16];
				Green = backgroundRAM_data[15:8];
				Blue = backgroundRAM_data[7:0];
			end // end_background
		end // end game_l
	end // end always_comb
	
	// Word Logic
	// signals if the current pixel is part of the word FIGHT
	word_FIGHT(.DrawX(DrawX),
					.DrawY(DrawY),
					.active(start_l),
					.start_x(FIGHT_x_start),
					.start_y(FIGHT_y_start),
					.n(FIGHT_n),
					.is_word(is_FIGHT)
					);
	
	// signals if the current pixel is part of the word DEFEAT
	word_DEFEAT(.DrawX(DrawX),
					.DrawY(DrawY),
					.active(lose_l),
					.start_x(DEFEAT_x_start),
					.start_y(DEFEAT_y_start),
					.n(DEFEAT_n),
					.is_word(is_DEFEAT)
					);
	
	// signals if the current pixel is part of the word VICTORY
	word_VICTORY(.DrawX(DrawX),
					.DrawY(DrawY),
					.active(win_l),
					.start_x(VICTORY_x_start),
					.start_y(VICTORY_y_start),
					.n(VICTORY_n),
					.is_word(is_VICTORY)
					);
 
endmodule
