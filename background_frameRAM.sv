/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  background_frameRAM
(
		input [9:0] read_address,
		input Clk,

		output logic [23:0] data_out
);

	// mem has width of 3 bits and a total of 400 addresses
	// 400 elements of 32 bits
	logic [23:0] mem [0:399];

	initial
	begin
		$readmemh("sprite_bytes/tetris_I.txt", mem);
	end
	

	always_ff @ (posedge Clk) begin
		data_out<= mem[read_address];
	end

endmodule
