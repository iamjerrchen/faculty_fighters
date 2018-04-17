module projectile(input				Clk,
											Reset,
											frame_clk,
						input [9:0]		Proj_X_Center,		// Shooter's Center
											Proj_Y_Center,
											Proj_X_Step,
											
						output logic [9:0]	Proj_X_Curr_Pos,
													Proj_Y_Curr_Pos,

						input				activate, contact,			// 
						
						input	[9:0]		DrawX, DrawY,		// Current pixel coordinates
						output logic	is_proj				// Whether pixel belongs to projectile or other
						);
						
	// Constants
	parameter [9:0] Proj_X_Min = 10'd0;       // Leftmost point on the X axis
	parameter [9:0] Proj_X_Max = 10'd639;     // Rightmost point on the X axis
	parameter [9:0] Proj_Y_Min = 10'd340;     // Topmost point on the Y axis
	parameter [9:0] Proj_Y_Max = 10'd380;     // Bottommost point on the Y axis
	//parameter [9:0] Proj_X_Step = 10'd4;      // Step size on the X axis
	parameter [9:0] Proj_Size = 10'd4;        // Projectile size
	
	logic [9:0] Proj_X_Pos, Proj_X_Motion, Proj_Y_Pos;
	logic [9:0] Proj_X_Pos_in, Proj_X_Motion_in, Proj_Y_Pos_in;
	logic 		is_active, is_active_in;
	
	assign Proj_X_Curr_Pos = Proj_X_Pos;
	assign Proj_Y_Curr_Pos = Proj_Y_Pos;
    
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
				// Stay fixed to shooter
				is_active <= 1'b0;
            Proj_X_Pos <= Proj_X_Center;
            Proj_Y_Pos <= Proj_Y_Center;
            Proj_X_Motion <= 10'd0;
        end
        else
        begin
				is_active <= is_active_in;
				if(is_active)
					begin
						Proj_X_Pos <= Proj_X_Pos_in;
						Proj_Y_Pos <= Proj_Y_Pos_in;
						Proj_X_Motion <= Proj_X_Motion_in;
					end
				else	// update pos with player
					begin
						Proj_X_Pos <= Proj_X_Center;
						Proj_Y_Pos <= Proj_Y_Center;
						Proj_X_Motion <= Proj_X_Motion_in;
					end
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
		  is_active_in = is_active;
        Proj_X_Pos_in = Proj_X_Pos;
        Proj_Y_Pos_in = Proj_Y_Pos;
        Proj_X_Motion_in = Proj_X_Motion;
        
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
				if(activate)
					begin
						Proj_X_Motion_in = Proj_X_Step;
						is_active_in = 1'b1;
					end
					
				// contact with target
 				if (contact || (Proj_X_Pos >= Proj_X_Max + Proj_Size))
					begin
						// Stay fixed to shooter
						is_active_in = 1'd0;
						Proj_X_Pos_in = Proj_X_Center;
						Proj_Y_Pos_in = Proj_Y_Center;
						Proj_X_Motion_in = 10'd0;
					end
				
            // Update the ball's position with its motion
            Proj_X_Pos_in = Proj_X_Pos + Proj_X_Motion;
        end
    end
    
	 // Logic for mapping proj to screen
    int DistX, DistY, Size;
    assign DistX = DrawX - Proj_X_Pos;
    assign DistY = DrawY - Proj_Y_Pos;
    assign Size = Proj_Size;
    always_comb begin
			if(is_active)
				begin
					if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
						is_proj = 1'b1;
					else
						is_proj = 1'b0;
				end
			else
            is_proj = 1'b0;
    end					
endmodule
