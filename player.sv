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
												Player_Y_Size,
					
					input						Up, Left, Right,
					//input						contact,
					
					input [7:0]				keycode,					// keycode exported form qsys
					input [9:0]				DrawX, DrawY,			// Current pixel coordinates
					
					input	[9:0]				sprite_size_x,
					
					output logic [4:0]	is_player_health,
					output logic [11:0]	Player_RAM_addr,		
					output logic			is_player,				// Whether current pixel belongs to player or background
												is_dead,
												
					input [9:0]				NPCs_Proj_X_curr,
												NPCs_Proj_Y_curr,
					output logic			bullet_player_contact
					);
   
	// constants
	parameter [9:0] Player_X_Min = 10'd0;       // Leftmost point on the X axis
	//parameter [9:0] Player_X_Max = 10'd639;   // Rightmost point on the X axis
	parameter [9:0] Player_Y_Min = 10'd290;     // Topmost point on the Y axis
	parameter [9:0] Player_Y_Max = 10'd420;     // Bottommost point on the Y axis
	parameter [9:0] Player_X_Step = 10'd1;      // Step size on the X axis
	parameter [9:0] Player_Y_Step = 10'd2;      // Step size on the Y axis
	parameter [9:0] Player_Size_X = 41;
	parameter [9:0] Player_Size_Y = 64; // 65
	
	parameter Player_Health_X = 10'd10;
	parameter Player_Health_Y = 10'd26;
	
	parameter Proj_X_Size = 10'd16;
	parameter Proj_Y_Size = 10'd11;
	logic contact;
	assign contact = bullet_player_contact;
	// bullet contact logic
	always_comb begin
		if(NPCs_Proj_X_curr + Proj_X_Size >= Player_X_Pos && NPCs_Proj_X_curr + Proj_X_Size< Player_X_Pos + Player_Size_X &&
			NPCs_Proj_Y_curr + 10'd2 >= Player_Y_Pos && NPCs_Proj_Y_curr + 10'd2 < Player_Y_Pos + Player_Size_Y)
			bullet_player_contact = 1'b1;
		else
			bullet_player_contact = 1'b0;
	end
	// end bullet contact logic
	
	
	logic triggered, hit;
	logic [4:0] player_health, player_health_in;
	logic [4:0] player_health_block;
	logic [3:0] Curr_Health;
	logic [9:0] Player_X_Pos, Player_X_Motion, Player_Y_Pos, Player_Y_Motion;
	logic [9:0] Player_X_Pos_in, Player_X_Motion_in, Player_Y_Pos_in, Player_Y_Motion_in;
	logic [9:0] Player_X_Incr, Player_Y_Incr, Player_X_Incr_in, Player_Y_Incr_in;
	
	assign Player_X_Size = Player_Size_X;
	assign Player_Y_Size = Player_Size_Y;
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
				Curr_Health <= 5'd5;
				Player_X_Pos <= Player_X_Init;
				Player_Y_Pos <= Player_Y_Init;
				Player_X_Incr <= 10'd0;
				Player_Y_Incr <= 10'd0;
				Player_X_Motion <= 10'd0;
				Player_Y_Motion <= 10'd0; //Ball_Y_Step;
				triggered <= 1'b0;
				is_dead <= 1'b0;
				player_health <= 5'b11111;
			end
		else
			begin
				// Health logic
				if(hit && (triggered != 1'b1))
				begin
					Curr_Health <= Curr_Health + (~Player_X_Step) + 1'b1;
					triggered <= 1'b1;
				end
				else
				begin
					Curr_Health <= Curr_Health;
					triggered <= 1'b0;
				end

				if(Curr_Health == 4'd0)
					is_dead <= 1'b1;
					
				is_player_health <= player_health_block & player_health_in;
				player_health <= player_health_in;
	
				// Position logic
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
		// player_health_in is controlled by synchronous player_health wires
		// so player_health_in will not decrement indefinitely
		player_health_in = player_health;
		if(triggered && hit)
			player_health_in = player_health >> 1;
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
				if(keycode == 8'd26 && (Player_Y_Motion == 1'b0))// Up) // W (up)
					begin
						Player_X_Incr_in = 1'b0;
						Player_Y_Incr_in = 1'b0;
						Player_Y_Motion_in = ~(Player_Y_Step) + 1'b1;
					end
				else if(keycode == 8'd4)//Left) // A (left)
					begin
						Player_X_Incr_in = ~(Player_X_Step) + 1'b1;
						Player_Y_Incr_in = 1'b0;
					end
				else if(keycode == 8'd7)//Right) // D (right)
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
				else if(Player_X_Pos <= Player_X_Min + 1'b1) // Ball is at the left edge, step back.
					begin
						Player_X_Incr_in = Player_X_Step;
					end
				
            // Update the ball's position with its motion and increment
            Player_X_Pos_in = Player_X_Pos + Player_X_Motion + Player_X_Incr;
            Player_Y_Pos_in = Player_Y_Pos + Player_Y_Motion + Player_Y_Incr;
        end
    end
	 
	 health player_healthbar(.DrawX(DrawX),
						.DrawY(DrawY),
						.Health_Pos_X(Player_Health_X),
						.Health_Pos_Y(Player_Health_Y),
						.is_health(player_health_block));
	 
	 hit_once_control hit_logic(.Clk(Clk),
										.Reset(Reset),
										.contact(contact),
										.triggered(triggered),
										.hit(hit));
	 
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
