module  npc ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
									  Soft_Reset,
                             frame_clk,          // The clock indicating a new frame (~60Hz)
					input [9:0]	  Ball_X_Center,
									  Ball_Y_Center,
					// Prevent overlap logic
					output logic [9:0] NPC_X_Curr_Pos, NPC_Y_Curr_Pos, // Outputting NPC current pos
				   input [9:0]	  Enemy_X_Curr_Pos,
									  Enemy_Y_Curr_Pos,
					output logic [9:0] Enemy_X_Size,
											 NPC_X_Size,
					
					input [7:0]	  keycode,				 // keycode exported form qsys
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
               output logic  is_ball             // Whether current pixel belongs to ball or background
              );
    
    //parameter [9:0] Ball_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min = 10'd340;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max = 10'd380;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step = 10'd1;      // Step size on the Y axis
    parameter [9:0] Ball_Size = 10'd4;        // Ball size
	 
    assign Ball_X_Size = Ball_Size;
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	 logic [9:0] Ball_X_Incr, Ball_Y_Incr, Ball_X_Incr_in, Ball_Y_Incr_in; // keystroke provides a signed increment amount
    
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
        if (Reset || Soft_Reset)
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Incr <= 10'd0;
				Ball_Y_Incr <= 10'd0;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
        end
        else
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
				NPC_X_Curr_Pos <= Ball_X_Pos_in;
				NPC_Y_Curr_Pos <= Ball_Y_Pos_in;
				Ball_X_Incr <= Ball_X_Incr_in;
				Ball_Y_Incr <= Ball_Y_Incr_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
		  Ball_X_Incr_in = Ball_X_Incr;
		  Ball_Y_Incr_in = Ball_Y_Incr;
        Ball_X_Motion_in = Ball_X_Motion;
        Ball_Y_Motion_in = Ball_Y_Motion;
        
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
				// Keypress logic
				if(keycode == 8'h52) // W (up)
					begin
						Ball_X_Incr_in = 1'b0;//Ball_X_Pos;
						Ball_Y_Incr_in = 1'b0;//Ball_Y_Pos - 1'b1;
						//Ball_X_Motion_in = 10'b0;
						Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1;
					end
				else if(keycode == 8'h50) // A (left)
					begin
						Ball_X_Incr_in = ~(Ball_X_Step) + 1'b1;
						Ball_Y_Incr_in = 1'b0;//Ball_Y_Pos;
						//Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1;
						//Ball_Y_Motion_in = 10'b0;
					end
				else if(keycode == 8'h51) // S (down)
					begin
						Ball_X_Incr_in = 1'b0;//Ball_X_Pos;
						Ball_Y_Incr_in = 1'b0;//Ball_Y_Pos;// + 1'b1;
						//Ball_X_Motion_in = 10'b0;
						//Ball_Y_Motion_in = Ball_Y_Step;
					end
				else if(keycode == 8'h4f) // D (right)
					begin
						Ball_X_Incr_in = 1'b1;//Ball_X_Pos + 1'b1;
						Ball_Y_Incr_in = 1'b0;//Ball_Y_Pos;
						//Ball_X_Motion_in = Ball_X_Step;
						//Ball_Y_Motion_in = 10'b0;
					end
				else
					begin
						Ball_X_Incr_in = 1'b0;
						Ball_Y_Incr_in = 1'b0;
					end
		  
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
            // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
            if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
					begin
						Ball_Y_Incr_in = ~(Ball_Y_Step) + 1'b1;// - 1'b1;
						//Ball_X_Pos_in = Ball_X_Pos;
						//Ball_X_Motion_in = 10'b0;
						Ball_Y_Motion_in = 10'b0; //(~(Ball_Y_Step) + 1'b1);  // 2's complement.  
					end
				else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size )  // Ball is at the top edge, BOUNCE!
                begin
						//Ball_Y_Pos_in = Ball_Y_Pos;// + 1'b1;
						//Ball_X_Pos_in = Ball_X_Pos;
						//Ball_X_Motion_in = 10'b0;
						Ball_Y_Motion_in = Ball_Y_Step;
					end
				// TODO: Add other boundary detections and handle keypress here.
				
				else if ( Ball_X_Pos + Ball_Size >= Ball_X_Max ) // Ball is at the right edge, STOP!
					begin
						//Ball_Y_Incr_in = 1'b0;
						Ball_X_Incr_in = ~(Ball_X_Step) + 1'b1;
						//Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1); 
						//Ball_Y_Motion_in = 10'b0;
					end
				else if ( Ball_X_Pos - Ball_Size <= Enemy_X_Curr_Pos + Enemy_X_Size) // Ball is at the left edge, STOP!
					begin
						//Ball_Y_Incr_in = 1'b0;
						Ball_X_Incr_in = 1'b1;
						//Ball_X_Motion_in = Ball_X_Step;
						//Ball_Y_Motion_in = 10'b0;
					end
				
            // Update the ball's position with its motion
            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion + Ball_X_Incr;
            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion + Ball_Y_Incr;
        end
    end
    
    // Compute whether the pixel corresponds to ball or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, Size;
    assign DistX = DrawX - Ball_X_Pos;
    assign DistY = DrawY - Ball_Y_Pos;
    assign Size = Ball_Size;
    always_comb begin
        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
            is_ball = 1'b1;
        else
            is_ball = 1'b0;
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
    end
    
endmodule
