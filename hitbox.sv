module hitbox(	input [9:0]		Obj_X,
										Obj_Y,
										Target_X,
										Target_Y,
										Coverage,
					output logic	contact
					);
					
	/* Since the multiplicants are required to be signed, we have to first cast them
	from logic to int (signed by default) before they are multiplied. */
	int DistX, DistY, Size;
	assign DistX = Obj_X - Target_Y;
	assign DistY = Obj_Y - Target_Y;
	assign Size = Coverage;
	always_comb begin
		// function only works with circles/ovals
		if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) )
			contact = 1'b1;
		else
			contact = 1'b0;
	end					
		
endmodule
