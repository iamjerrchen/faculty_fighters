// This module should place the boxes. Logic for controller the existence should be from player/npc
module health(	input [9:0]				DrawX,
												DrawY,
					input [9:0] 			Health_Pos_X,	// start position: shouldn't move
												Health_Pos_Y,	// start position: shouldn't move
										
					
					
					output logic [4:0]	is_health
					);

	parameter size = 5'd16;
	parameter Offset = 4'd4;
					
	logic [9:0] PosX1, PosX2, PosX3, PosX4, PosX5;
	
	// offset boxes from each other
	assign PosX1 = Health_Pos_X;
	assign PosX2 = PosX1 + size + Offset;
	assign PosX3 = PosX2 + size + Offset;
	assign PosX4 = PosX3 + size + Offset;
	assign PosX5 = PosX4 + size + Offset;
	
	box pt1(.DrawX(DrawX),
				.DrawY(DrawY),
				.Pos_X(PosX1),
				.Pos_Y(Health_Pos_Y),
				.is_box(is_health[0]));
					
	box pt2(.DrawX(DrawX),
				.DrawY(DrawY),
				.Pos_X(PosX2),
				.Pos_Y(Health_Pos_Y),
				.is_box(is_health[1]));
					
	box pt3(.DrawX(DrawX),
				.DrawY(DrawY),
				.Pos_X(PosX3),
				.Pos_Y(Health_Pos_Y),
				.is_box(is_health[2]));
					
	box pt4(.DrawX(DrawX),
				.DrawY(DrawY),
				.Pos_X(PosX4),
				.Pos_Y(Health_Pos_Y),
				.is_box(is_health[3]));
					
	box pt5(.DrawX(DrawX),
				.DrawY(DrawY),
				.Pos_X(PosX5),
				.Pos_Y(Health_Pos_Y),
				.is_box(is_health[4]));
				
endmodule
