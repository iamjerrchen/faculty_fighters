module box(	input [9:0]				DrawX,
											DrawY,
											
											Pos_X,
											Pos_Y,
																						
						output logic is_box);
	
	parameter size = 5'd16;
	parameter [0:15][15:0] sprite = {
		16'b0000000000000000, // 0
		16'b0000000000000000, // 1
		16'b0011100000011100, // 2
		16'b0111110000111110, // 3
		16'b1111110000111111, // 4
		16'b1111111001111111, // 5
		16'b1111111111111111, // 6
		16'b1111111111111111, // 7
		16'b1111111111111111, // 8
		16'b0111111111111110, // 9
		16'b0011111111111100, // 10
		16'b0001111111111000, // 11
		16'b0000111111110000, // 12
		16'b0000011111100000, // 13
		16'b0000001111000000, // 14
		16'b0000000110000000 // 15
		};
					
	logic	[4:0] yidx, xidx;
	assign yidx = (DrawY - Pos_Y);
	assign xidx = (DrawX - Pos_X);
				
	// existence of box
	always_comb
	begin
		if(DrawX >= Pos_X && DrawX < Pos_X + size &&
			DrawY >= Pos_Y && DrawY < Pos_Y + size &&
			sprite[yidx][xidx])
			is_box = 1'b1;
		else
			is_box = 1'b0;
	end

endmodule
