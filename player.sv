module  player (input					Clk,						// 50 MHz clock
												Reset,					// Active-high reset signal
												frame_clk,				// The clock indicating a new frame (~60Hz)
					input [9:0]				Player_X_Center,
												Player_Y_Center,
												
					input [9:0]	  			Enemy_X_Curr_Pos,
												Enemy_Y_Curr_Pos,
					input [9:0] 			Enemy_X_Size,
					
					// Outputting Player current pos
					output logic [9:0] 	Player_X_Curr_Pos,
												Player_Y_Curr_Pos,
												Player_X_Size,
					
					input						Up, Left, Right,
					
					input [7:0]				keycode,					// keycode exported form qsys
					input [9:0]				DrawX, DrawY,			// Current pixel coordinates
					output logic			is_player				// Whether current pixel belongs to player or background
              );
   
	// constants
	parameter [9:0] Player_X_Min = 10'd0;       // Leftmost point on the X axis
	//parameter [9:0] Player_X_Max = 10'd639;     // Rightmost point on the X axis
	parameter [9:0] Player_Y_Min = 10'd340;       // Topmost point on the Y axis
	parameter [9:0] Player_Y_Max = 10'd381;     // Bottommost point on the Y axis
	parameter [9:0] Player_X_Step = 10'd1;      // Step size on the X axis
	parameter [9:0] Player_Y_Step = 10'd1;      // Step size on the Y axis
	parameter [9:0] Player_Size = 10'd4;        // Ball size
	
	logic [9:0] Player_X_Pos, Player_X_Motion, Player_Y_Pos, Player_Y_Motion;
	logic [9:0] Player_X_Pos_in, Player_X_Motion_in, Player_Y_Pos_in, Player_Y_Motion_in;
	logic [9:0] Player_X_Incr, Player_Y_Incr, Player_X_Incr_in, Player_Y_Incr_in;
	
	assign Player_X_Size = Player_Size;
	assign Player_X_Curr_Pos = Player_X_Pos;
	assign Player_Y_Curr_Pos = Player_Y_Pos;
	
	//////// Do not modify the always_ff blocks. ////////
	// Detect rising edge of frame_clk
	logic frame_clk_delayed, frame_clk_rising_edge;
	always_ff @ (posedge Clk) begin
		frame_clk_delayed <= frame_clk;
		frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
	end
	//////// Do not modify the always_ff blocks. ////////
	
	// Update registers
	always_ff @ (posedge Clk)
	begin
		if (Reset)
			begin
				Player_X_Pos <= Player_X_Center;
				Player_Y_Pos <= Player_Y_Center;
				Player_X_Incr <= 10'd0;
				Player_Y_Incr <= 10'd0;
				Player_X_Motion <= 10'd0;
				Player_Y_Motion <= 10'd0; //Ball_Y_Step;
			end
		else
			begin
				Player_X_Pos <= Player_X_Pos_in;
				Player_Y_Pos <= Player_Y_Pos_in;
				Player_X_Incr <= Player_X_Incr_in;
				Player_Y_Incr <= Player_Y_Incr_in;
				Player_X_Motion <= Player_X_Motion_in;
				Player_Y_Motion <= Player_Y_Motion_in;
			end
	end
	
	
	always_comb
	begin
		// By default, keep motion and position unchanged
		Player_X_Pos_in = Player_X_Pos;
		Player_Y_Pos_in = Player_Y_Pos;
		Player_X_Incr_in = Player_X_Incr;
		Player_Y_Incr_in = Player_Y_Incr;
		Player_X_Motion_in = Player_X_Motion;
		Player_Y_Motion_in = Player_Y_Motion;
		
		// Update position and motion only at rising edge of frame clock
		if (frame_clk_rising_edge)
			begin
				// Keypress logic
				if(Up)//keycode == 8'd26) // W (up)
					begin
						Player_X_Incr_in = 1'b0;
						Player_Y_Incr_in = 1'b0;
						Player_Y_Motion_in = ~(Player_Y_Step) + 1'b1;
					end
				else if(Left)//keycode == 8'd4) // A (left)
					begin
						Player_X_Incr_in = ~(Player_X_Step) + 1'b1;
						Player_Y_Incr_in = 1'b0;
					end
				else if(keycode == 8'd22) // S (down)
					begin
						Player_X_Incr_in = 1'b0;;
						Player_Y_Incr_in = 1'b0;
					end
				else if(Right)//keycode == 8'd7) // D (right)
					begin
						Player_X_Incr_in = Player_X_Step;
						Player_Y_Incr_in = 1'b0;;
					end
				else
					begin
						Player_X_Incr_in = 1'b0;
						Player_Y_Incr_in = 1'b0;
					end
					
				// Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
            // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
            if(Player_Y_Pos + Player_Size >= Player_Y_Max)  // Ball is at the bottom edge, BOUNCE!
					begin
						Player_Y_Incr_in = ~(Player_Y_Step) + 1'b1;
						Player_Y_Motion_in = 10'b0;
					end
				else if(Player_Y_Pos <= Player_Y_Min + Player_Size)  // Ball is at the top edge, BOUNCE!
                begin
						Player_Y_Motion_in = Player_Y_Step;
					end
				else if(Player_X_Pos + Player_Size >= Enemy_X_Curr_Pos + ~(Enemy_X_Size) + 1'b1) // Ball is at the right edge, BOUNCE!
					begin
						Player_X_Incr_in = ~(Player_X_Step) + 1'b1;
					end
				else if(Player_X_Pos <= Player_X_Min + Player_Size) // Ball is at the left edge, BOUNCE!
					begin
						Player_X_Incr_in = Player_X_Step;
					end
				
            // Update the ball's position with its motion and increment
            Player_X_Pos_in = Player_X_Pos + Player_X_Motion + Player_X_Incr;
            Player_Y_Pos_in = Player_Y_Pos + Player_Y_Motion + Player_Y_Incr;
        end
    end
    
    // Compute whether the pixel corresponds to ball or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, Size;
    assign DistX = DrawX - Player_X_Pos;
    assign DistY = DrawY - Player_Y_Pos;
    assign Size = Player_Size;
    always_comb begin
        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
            is_player = 1'b1;
        else
            is_player = 1'b0;
    end
endmodule
