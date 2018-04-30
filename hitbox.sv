module hitbox(	input [9:0]		Obj_X,
										Obj_Y,
										
										Target_X,
										Target_Y,
										
										Target_X_Size,
										Target_Y_Size,
										
					output logic	contact
					);

	// assuming Target_X and Target_Y are top left pixel_Y;
	always_comb begin
		// function only works with circles/ovals
		if(Obj_X >= Target_X && Obj_X < Target_X + Target_X_Size &&
			Obj_Y >= Target_Y && Obj_Y < Target_Y + Target_Y_Size)
			contact = 1'b1;
		else
			contact = 1'b0;
	end					
		
endmodule
