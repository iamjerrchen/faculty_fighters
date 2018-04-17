// Two-always state machine
// This module controls the stages in the game.
// Start screen, battle screen, and end screens.
module stage_control (
							input logic 	Clk,		// Frame Clock
							input logic 	Reset,	// System Wide Reset
							
							// State change conditions, Active High
							input logic 	Fight,
												Restart,
												Player_Dead,
												NPC_Dead,
							
							// Logic signals
							output logic 	start_l,
												game_l,
												win_l,
												lose_l
							);

	// Declare signals curr_state, next_state of type enum
	enum logic [1:0] {START, BATTLE, WIN, LOSE}	curr_state, next_state; 

	// Updates flip flop, current state is the only one
	always_ff @ (posedge Clk)  
	begin
		if(Restart || Reset)
			curr_state <= START;
		else 
			curr_state <= next_state;
	end
	
	// Assign outputs based on state
	always_comb
		begin
		
			next_state = curr_state;
			unique case (curr_state) 
			
				START:	if(Fight)
								next_state = BATTLE;
				BATTLE:		if(NPC_Dead)
								next_state = WIN;
							else if(Player_Dead)
								next_state = LOSE;
								
				// Stay in state til released
				WIN:		if(~NPC_Dead)
								next_state = START;
				LOSE:		if(~Player_Dead)
								next_state = START;
								
			endcase
			
			
			// Assign outputs based on ‘state’
			case (curr_state)
				START: 
					begin
						start_l = 1'b1;
						game_l = 1'b0;
						win_l = 1'b0;
						lose_l = 1'b0;
					end
				
				WIN: 
					begin
						start_l = 1'b0;
						game_l = 1'b0;
						win_l = 1'b1;
						lose_l = 1'b0;
					end
					
				LOSE:
					begin
						start_l = 1'b0;
						game_l = 1'b0;
						win_l = 1'b0;
						lose_l = 1'b1;
					end
					
				default: // default in battle state
					begin 
						start_l = 1'b0;
						game_l = 1'b1;
						win_l = 1'b0;
						lose_l = 1'b0;
					end
        endcase
    end

endmodule
