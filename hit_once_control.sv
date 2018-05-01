module hit_once_control(input logic 	Clk,
													Reset,
						
								input logic		contact,
								input logic		triggered, // his has registered
								
								output logic	hit
								);

	// declare signal curr_state, next_state of type enum
	enum logic [1:0] {START, TRIGGER, ACTIVE} curr_state, next_state;

	always_ff @ (posedge Clk)
	begin
		if(Reset)
			curr_state <= START;
		else
			curr_state <= next_state;
	end

	// Assign outputs based on state
	always_comb
		begin
			
			next_state = curr_state;
			unique case (curr_state)
			
				START:	if(contact)
								next_state = TRIGGER;

				TRIGGER:	if(triggered)
								next_state = ACTIVE;
				
				ACTIVE:	if(~contact)
								next_state = START;
				
			endcase
				
			// Assign outputs based on 'state'
			case (curr_state)
				TRIGGER:
					hit = 1'b1;
					
				default:
					hit = 1'b0;

			endcase
		end
endmodule
