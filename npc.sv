module npc (input						Clk,                // 50 MHz clock
											Reset,              // Active-high reset signal
											frame_clk,          // The clock indicating a new frame (~60Hz)
				input [9:0]				NPC_X_Init,
											NPC_Y_Init,
				
				input [9:0]				Enemy_X_Curr_Pos,
											Enemy_Y_Curr_Pos,
											Enemy_X_Size,
										
				// Outputting NPC current pos
				output logic [9:0] 	NPC_X_Curr_Pos,
											NPC_Y_Curr_Pos, 
											NPC_X_Size,
											
				input						Up, Left, Right,
				
				input [7:0]				keycode,					// keycode exported form qsys
				input [9:0]				DrawX, DrawY,			// Current pixel coordinates
				output logic			is_npc					// Whether current pixel belongs to ball or background
				);
    
	// constants
   //parameter [9:0] NPC_X_Min = 10'd0;     // Leftmost point on the X axis
	parameter [9:0] NPC_X_Max = 10'd639;     // Rightmost point on the X axis
	parameter [9:0] NPC_Y_Min = 10'd340;     // Topmost point on the Y axis
	parameter [9:0] NPC_Y_Max = 10'd381;     // Bottommost point on the Y axis
	parameter [9:0] NPC_X_Step = 10'd1;      // Step size on the X axis
	parameter [9:0] NPC_Y_Step = 10'd1;      // Step size on the Y axis
	parameter [9:0] NPC_Size = 10'd4;        // Ball size
	 
	logic [9:0] NPC_X_Pos, NPC_X_Motion, NPC_Y_Pos, NPC_Y_Motion;
	logic [9:0] NPC_X_Pos_in, NPC_X_Motion_in, NPC_Y_Pos_in, NPC_Y_Motion_in;
	logic [9:0] NPC_X_Incr, NPC_Y_Incr, NPC_X_Incr_in, NPC_Y_Incr_in; // keystroke provides an increment amount
	 
	assign NPC_X_Size = NPC_Size;
	assign NPC_X_Curr_Pos = NPC_X_Pos;
	assign NPC_Y_Curr_Pos = NPC_Y_Pos;
	
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
				NPC_X_Pos <= NPC_X_Init;
				NPC_Y_Pos <= NPC_Y_Init;
				NPC_X_Incr <= 10'd0;
				NPC_Y_Incr <= 10'd0;
				NPC_X_Motion <= 10'd0;
				NPC_Y_Motion <= 10'd0;
			end
		else
			begin
				NPC_X_Pos <= NPC_X_Pos_in;
				NPC_Y_Pos <= NPC_Y_Pos_in;
				NPC_X_Incr <= NPC_X_Incr_in;
				NPC_Y_Incr <= NPC_Y_Incr_in;
				NPC_X_Motion <= NPC_X_Motion_in;
				NPC_Y_Motion <= NPC_Y_Motion_in;
			end
	end
	
	// You need to modify always_comb block.
	always_comb
	begin
		// By default, keep motion and position unchanged
		NPC_X_Pos_in = NPC_X_Pos;
		NPC_Y_Pos_in = NPC_Y_Pos;
		NPC_X_Incr_in = NPC_X_Incr;
		NPC_Y_Incr_in = NPC_Y_Incr;
		NPC_X_Motion_in = NPC_X_Motion;
		NPC_Y_Motion_in = NPC_Y_Motion;
		
		// Update position and motion only at rising edge of frame clock
		if (frame_clk_rising_edge)
			begin
				// Keypress logic
				if(Up)//keycode == 8'h52) // W (up)
					begin
						NPC_X_Incr_in = 1'b0;
						NPC_Y_Incr_in = 1'b0;
						NPC_Y_Motion_in = ~(NPC_Y_Step) + 1'b1;
					end
				else if(Left)//keycode == 8'h50) // A (left)
					begin
						NPC_X_Incr_in = ~(NPC_X_Step) + 1'b1;
						NPC_Y_Incr_in = 1'b0;
					end
				else if(keycode == 8'h51) // S (down)
					begin
						NPC_X_Incr_in = 1'b0;
						NPC_Y_Incr_in = 1'b0;
					end
				else if(Right)//keycode == 8'h4f) // D (right)
					begin
						NPC_X_Incr_in = 1'b1;
						NPC_Y_Incr_in = 1'b0;
					end
				else
					begin
						NPC_X_Incr_in = 1'b0;
						NPC_Y_Incr_in = 1'b0;
					end
					
				// Be careful when using comparators with "logic" datatype because compiler treats 
				//   both sides of the operator as UNSIGNED numbers.
				if(NPC_Y_Pos + NPC_Size >= NPC_Y_Max)  // Ball is at the bottom edge, STOP!
					begin
						NPC_Y_Incr_in = ~(NPC_Y_Step) + 1'b1;
						NPC_Y_Motion_in = 10'b0; 
					end
				else if (NPC_Y_Pos <= NPC_Y_Min + NPC_Size)  // Ball is at the top edge, BOUNCE!
					begin
						NPC_Y_Motion_in = NPC_Y_Step;
					end
				else if (NPC_X_Pos + NPC_Size >= NPC_X_Max) // Ball is at the right edge, step back.
					begin
						NPC_X_Incr_in = ~(NPC_X_Step) + 1'b1;
					end
				else if (NPC_X_Pos - NPC_Size <= Enemy_X_Curr_Pos + Enemy_X_Size) // Ball is at the left edge, step back.
					begin
						NPC_X_Incr_in = NPC_X_Step;
					end
					
				// Update the ball's position with its motion
				NPC_X_Pos_in = NPC_X_Pos + NPC_X_Motion + NPC_X_Incr;
				NPC_Y_Pos_in = NPC_Y_Pos + NPC_Y_Motion + NPC_Y_Incr;
			end
	end
	
	// Compute whether the pixel corresponds to ball or background
	/* Since the multiplicants are required to be signed, we have to first cast them
		from logic to int (signed by default) before they are multiplied. */
	int DistX, DistY, Size;
	assign DistX = DrawX - NPC_X_Pos;
	assign DistY = DrawY - NPC_Y_Pos;
	assign Size = NPC_Size;
	always_comb begin
		if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
			is_npc = 1'b1;
		else
			is_npc = 1'b0;
	end
endmodule
