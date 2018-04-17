//Two-always example for state machine
// This module is a state machine to control the stages in the game.
// Start screen, game screen, and end screen.
module stage_control (
							input logic 	Clk,		// uses frame clk
							input logic 	Reset,
							
							// state change conditions, Active High
							input logic 	Fight,
												Restart,
												Player_Dead,
												NPC_Dead,
							
							// logic signals
							output logic 	start_l,
												game_l,
												win_l,
												lose_l
							);

	// Declare signals curr_state, next_state of type enum
	// with enum values of A, B, ..., F as the state values
	// Note that the length implies a max of 8 states, so you will need to bump this up for 8-bits
	enum logic [2:0] {START, GAME, WIN, LOSE, END}	curr_state, next_state; 

	//updates flip flop, current state is the only one
	always_ff @ (posedge Clk)  
	begin
		if(Restart)
			curr_state <= START;
		else 
			curr_state <= next_state;
	end
	
	// Assign outputs based on state
	always_comb
		begin
		
			next_state = curr_state;	//required because I haven't enumerated all possibilities below
			unique case (curr_state) 
			
				START:	if(Fight)// Clear A, Load B bit is on
								next_state = GAME;
				GAME:		if(NPC_Dead)
								next_state = WIN;
							else if(Player_Dead)
								next_state = LOSE;
								
				// stay in state til released
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
					
				default: // default in game state
					begin 
						start_l = 1'b0;
						game_l = 1'b1;
						win_l = 1'b0;
						lose_l = 1'b0;
					end
        endcase
    end

endmodule
