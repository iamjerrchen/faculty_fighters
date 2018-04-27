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
module  color_mapper ( input              is_ball1,            // Whether current pixel belongs to ball 
														is_ball2,
														is_proj,
														// stage
														start_l,
														battle_l,
														win_l,
														lose_l,
														
                                                              //   or background (computed in ball.sv)
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
							
	parameter [9:0] font_x_start = 200;
	parameter [9:0] font_y_start = 400;
	parameter [9:0] font_size_x = 8;
	parameter [9:0] font_size_y = 16;
	
	logic [7:0] Red, Green, Blue;
	logic [9:0] font_addr; // addressing font_rom
	logic [7:0] font_bitmap; // data from rom
	logic char_on;
	
	font_rom (.addr(font_addr),
				.data(font_bitmap)
				);
	
	// Output colors to VGA
	assign VGA_R = Red;
	assign VGA_G = Green;
	assign VGA_B = Blue;
   
	always_comb
	begin
		if(DrawX >= font_x_start && DrawX < font_x_start + font_size_x &&
			DrawY >= font_y_start && DrawY < font_y_start + font_size_y)
			char_on = 1'b1;
		else
			char_on = 1'b0;
	end

	// Assign color based on is_ball signal
	always_comb
	begin
		font_addr = (DrawY - font_y_start + 16*'hf);
		if (start_l)
		begin
			// Text
			if((char_on == 1'b1) && (font_bitmap[7 - DrawX - font_x_start] == 1'b1))
			begin
				Red = 8'hff;
				Green = 8'hff;
				Blue = 8'hff;
			end
			else if(char_on == 1'b1 && (font_bitmap[7- DrawX - font_x_start] == 1'b0))
			begin
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
			end
			else
			begin
				// Background
				Red = 8'hFF;
				Green = 8'h6D;
				Blue = 8'h00;
			end
		end // end start_l
		
		else if(win_l)
		begin
			// blood red
			Red = 8'h9C;
			Green = 8'h1D;
			Blue = 8'h08;
		end // end win_l
		
		else if(lose_l)
		begin
			// dark purple
			Red = 8'h57;
			Green = 8'h00;
			Blue = 8'h7F;
		end // end lose_l
		
		else //if(game_l)
		begin
			// characters
			if (is_ball1 == 1'b1) 
			begin
				// White ball
				Red = 8'hff;
				Green = 8'hff;
				Blue = 8'hff;
			end
			else if (is_ball2 == 1'b1)
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
				if (DrawY >= 10'd380)
				begin
					// platform
					Red = 8'h00;
					Green = 8'hff;
					Blue = 8'h00;
				end
				else
				begin
					// Background with nice color gradient
					Red = 8'h3f; 
					Green = 8'h00;
					Blue = 8'h7f - {1'b0, DrawX[9:3]};
				end
			end // end_background
		end // end game_l
	end // end always_comb
    
endmodule
