module player (input						Clk,						// 50 MHz clock
												Reset,					// Active-high reset signal
												frame_clk,				// The clock indicating a new frame (~60Hz)
					input [9:0]				Player_X_Init,
												Player_Y_Init,
												
					input [9:0]	  			Enemy_X_Curr_Pos,
												Enemy_Y_Curr_Pos,
												Enemy_X_Size,
					
					// Outputting Player current pos
					output logic [9:0] 	Player_X_Curr_Pos,
												Player_Y_Curr_Pos,
												Player_X_Size,
					
					input						Up, Left, Right,
					
					input [7:0]				keycode,					// keycode exported form qsys
					input [9:0]				DrawX, DrawY,			// Current pixel coordinates
					
					input	[9:0]				sprite_size_x,
					output logic [11:0]	Player_RAM_addr,		
					output logic			is_player				// Whether current pixel belongs to player or background
				  );
   
	// constants
	parameter [9:0] Player_X_Min = 10'd0;       // Leftmost point on the X axis
	//parameter [9:0] Player_X_Max = 10'd639;   // Rightmost point on the X axis
	parameter [9:0] Player_Y_Min = 10'd290;     // Topmost point on the Y axis
	parameter [9:0] Player_Y_Max = 10'd420;     // Bottommost point on the Y axis
	parameter [9:0] Player_X_Step = 10'd1;      // Step size on the X axis
	parameter [9:0] Player_Y_Step = 10'd1;      // Step size on the Y axis
	parameter [9:0] Player_Size_X = 41;
	parameter [9:0] Player_Size_Y = 64; // 65
	
	logic [9:0] Player_X_Pos, Player_X_Motion, Player_Y_Pos, Player_Y_Motion;
	logic [9:0] Player_X_Pos_in, Player_X_Motion_in, Player_Y_Pos_in, Player_Y_Motion_in;
	logic [9:0] Player_X_Incr, Player_Y_Incr, Player_X_Incr_in, Player_Y_Incr_in;
	
	assign Player_X_Size = Player_Size_X;
	assign Player_X_Curr_Pos = Player_X_Pos;
	assign Player_Y_Curr_Pos = Player_Y_Pos;
	
	assign Player_RAM_addr = (DrawY - Player_Y_Pos)*sprite_size_x + (DrawX - Player_X_Pos); // access sprite left to right
	
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
				Player_X_Pos <= Player_X_Init;
				Player_Y_Pos <= Player_Y_Init;
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
				if(Up && (Player_Y_Motion != 1'b1))//keycode == 8'd26) // W (up)
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
						Player_X_Incr_in = 1'b0;
						Player_Y_Incr_in = 1'b0;
					end
				else if(Right)//keycode == 8'd7) // D (right)
					begin
						Player_X_Incr_in = Player_X_Step;
						Player_Y_Incr_in = 1'b0;
					end
				else
					begin
						Player_X_Incr_in = 1'b0;
						Player_Y_Incr_in = 1'b0;
					end
					
				// Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            if(Player_Y_Pos + Player_Size_Y >= Player_Y_Max)  // Ball is at the bottom edge, STOP!
					begin
						Player_Y_Incr_in = ~(Player_Y_Step) + 1'b1;
						Player_Y_Motion_in = 10'b0;
					end
				else if(Player_Y_Pos <= Player_Y_Min)  // Ball is at the top edge, BOUNCE!
                begin
						Player_Y_Motion_in = Player_Y_Step;
					end
				else if(Player_X_Pos + Player_Size_X >= Enemy_X_Curr_Pos) // Ball is at the right edge, step back.
					begin
						Player_X_Incr_in = ~(Player_X_Step) + 1'b1;
					end
				else if(Player_X_Pos <= Player_X_Min) // Ball is at the left edge, step back.
					begin
						Player_X_Incr_in = Player_X_Step;
					end
				
            // Update the ball's position with its motion and increment
            Player_X_Pos_in = Player_X_Pos + Player_X_Motion + Player_X_Incr;
            Player_Y_Pos_in = Player_Y_Pos + Player_Y_Motion + Player_Y_Incr;
        end
    end
	 
	 // If current pixel is the character
    always_comb
	 begin
        if (DrawX >= Player_X_Pos && DrawX < Player_X_Pos + Player_Size_X &&
				DrawY >= Player_Y_Pos && DrawY < Player_Y_Pos + Player_Size_Y) 
            is_player = 1'b1;
        else
            is_player = 1'b0;
    end
endmodule
