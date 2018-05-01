module fireball_animation_control(input logic 			Clk,
																		Reset,
																	
											input logic	 			is_active,
											
											output logic [3:0]	idx_offset
											);

	// declare signal curr_state, next_state of type enum
	enum logic [2:0] {START, OFFSET_1, OFFSET_2, OFFSET_3} curr_state, next_state;
	logic [9:0] counter; // delay
	
	always_ff @ (posedge Clk)
	begin
		if(Reset)
		begin
			curr_state <= START;
			counter <= 10'd0;
		end
		else
		begin
			if(counter < 10'd30)
			begin
				counter <= counter + 1'b1;
				curr_state <= curr_state;
			end
			else
			begin
				counter <= 10'd0;
				curr_state <= next_state;
			end
		end
	end
	
	
	always_comb
		begin
		
			next_state = curr_state;
			unique case (curr_state)
			
				START:		if(is_active)
									next_state = OFFSET_1;
				
				OFFSET_1:	next_state = OFFSET_2;
				
				OFFSET_2:	next_state = OFFSET_3;
				
				OFFSET_3:	if(~is_active)
									next_state = START;
								else
									next_state = OFFSET_1;
			
			endcase

			// Assign outputs based on 'state'
			case (curr_state)
				OFFSET_1:
					idx_offset = 4'd1;
				OFFSET_2:
					idx_offset = 4'd2;
				OFFSET_3:
					idx_offset = 4'd3;
				default:
					idx_offset = 4'd0;
			
			endcase
		end
endmodule
