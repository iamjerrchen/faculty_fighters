/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  background_frameRAM
(
		input [9:0] 	DrawX,
							DrawY,
		input Clk,

		output logic [23:0] data_out
);
	parameter bit [0:7][23:0] palette = {24'h79caf9,
												24'h7fac71,
												24'hf4f7fc,
												24'he6e5f3,
												24'hb0e767,
												24'hbadcdb,
												24'h6a92f2,
												24'hb8e1f7};
	
	parameter [9:0] mem_seg_x_start = 0;
	parameter [9:0] mem_seg_x_size = 640;
	parameter [9:0] mem_seg_y_size = 177;
	parameter [9:0] mem_seg_y_start = 253;
	parameter [9:0] mem_seg_y_end = 430;
	
	// mem has width of 3 bits and a total of 400 addresses
	// 400 elements of 32 bits
	//logic [23:0] mem [0:399];
	logic [3:0] mem [0:113279]; // 640*480 = 307200 pixels
	logic [3:0] LUT_idx;
	logic [16:0] address;

	initial
	begin
		$readmemh("sprite_bytes/background.txt", mem);
	end
	
	assign address = (DrawY - mem_seg_y_start)*mem_seg_x_size + (DrawX - mem_seg_x_start);
	
	always_comb
	begin
		LUT_idx = mem[address];
		if(DrawY <= mem_seg_y_start)
			data_out = 24'h79caf9;
		else if(DrawY >= mem_seg_y_end)
			data_out = 24'h7fac71;
		else
			data_out = palette[LUT_idx];
	end

endmodule
