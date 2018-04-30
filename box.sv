module box(	input [9:0]		DrawX,
											DrawY,
											
											Pos_X,
											Pos_Y,
											
											size,	// size*size dimensions
																						
						output logic is_box);
						
	// existence of box
	always_comb
	begin
		if(DrawX >= Pos_X && DrawX < Pos_X + size &&
			DrawY >= Pos_Y && DrawY < Pos_Y + size)
			is_box = 1'b1;
		else
			is_box = 1'b0;
	end

endmodule
