module faculty_fighter_top_level(
											input	CLOCK_50,
											input        [3:0]  	KEY,          //bit 0 is set up as Reset
											input			 [15:0]	SW,			  //switches
											output logic [6:0]  	HEX0, HEX1,
											
											// VGA Interface 
											output logic [7:0]  	VGA_R,        //VGA Red
																		VGA_G,        //VGA Green
																		VGA_B,        //VGA Blue
											output logic			VGA_CLK,      //VGA Clock
																		VGA_SYNC_N,   //VGA Sync signal
																		VGA_BLANK_N,  //VGA Blank signal
																		VGA_VS,       //VGA virtical sync signal
																		VGA_HS,       //VGA horizontal sync signal
											
											// CY7C67200 Interface
											inout  wire  [15:0] 	OTG_DATA,     //CY7C67200 Data bus 16 Bits
											output logic [1:0]  	OTG_ADDR,     //CY7C67200 Address 2 Bits
											output logic        	OTG_CS_N,     //CY7C67200 Chip Select
																		OTG_RD_N,     //CY7C67200 Write
																		OTG_WR_N,     //CY7C67200 Read
																		OTG_RST_N,    //CY7C67200 Reset
											input               	OTG_INT,      //CY7C67200 Interrupt
											
											// SDRAM Interface for Nios II Software
											output logic [12:0] 	DRAM_ADDR,    //SDRAM Address 13 Bits
											inout  wire  [31:0] 	DRAM_DQ,      //SDRAM Data 32 Bits
											output logic [1:0]  	DRAM_BA,      //SDRAM Bank Address 2 Bits
											output logic [3:0]  	DRAM_DQM,     //SDRAM Data Mast 4 Bits
											output logic        	DRAM_RAS_N,   //SDRAM Row Address Strobe
																		DRAM_CAS_N,   //SDRAM Column Address Strobe
																		DRAM_CKE,     //SDRAM Clock Enable
																		DRAM_WE_N,    //SDRAM Write Enable
																		DRAM_CS_N,    //SDRAM Chip Select
																		DRAM_CLK      //SDRAM Clock
											);
    
    logic Reset_h, Clk;
    logic [7:0] keycode;
	 logic Shoot_h;
    
	 // synchronizer
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
		  Soft_Reset_h <= ~(KEY[3]);
		  // temporary
		  Shoot_h <= ~(KEY[2]);
		  NPC_Up_h <= ~(KEY[1]);
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
    // You need to make sure that the port names here match the ports in Qsys-generated codes.
    faculty_fighter_soc nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
	 logic [9:0] DrawX, DrawY;
    VGA_controller vga_controller_instance(.Clk(Clk),
														.Reset(Reset_h),
														.VGA_HS(VGA_HS),
														.VGA_VS(VGA_VS),
														.VGA_CLK(VGA_CLK),
														.VGA_BLANK_N(VGA_BLANK_N),
														.VGA_SYNC_N(VGA_SYNC_N),
														.DrawX(DrawX),
														.DrawY(DrawY));
    
	 
	 ////////// ADD STUFF HERE ///////////
	 
	 logic is_player, is_npc, is_proj;
	 logic player_pixel_on, npc_pixel_on;
	 logic bullet_contact;
	 
	 logic [23:0] player_pixel, npc_pixel;
	 logic [11:0] Player_RAM_addr, NPC_RAM_addr;
	 logic [9:0] sprite_size_x;
	 
	 // constants for characters
	 parameter Player_X_Init = 10'd260;
	 parameter Player_Y_Init = 10'd355;
	 parameter NPC_X_Init = 10'd360;
	 parameter NPC_Y_Init = 10'd355;
	 parameter Proj_X_Speed = 10'd4;
	 
	 logic [9:0] Player_X_Size, NPC_X_Size;
	 logic [9:0] Player_X_curr, Player_Y_curr, NPC_X_curr, NPC_Y_curr, Proj_X_curr, Proj_Y_curr;
	 
	 // Input Control
	 logic Player_Up, Player_Right, Player_Left, NPC_Right, NPC_Left;
	 logic Restart;
	 assign Player_Up = SW[13];
	 assign Player_Right = SW[14];
	 assign Player_Left = SW[15];
	 assign NPC_Right = SW[0];
	 assign NPC_Left = SW[1];
	 assign Restart = SW[11];
	 
	 // temporary
	 logic Player_Dead, NPC_Dead;
	 assign Player_Dead = SW[10];
	 assign NPC_Dead = SW[9];
	 
	 // state output
	 logic start_l, battle_l, win_l, lose_l;
	 
	 stage_control stages(.Clk(VGA_VS), // update state based on frame? or Clk
								.Reset(Reset_h),
								
								.Fight(Soft_Reset_h),
								.Restart(Restart),
								.Player_Dead(Player_Dead),
								.NPC_Dead(NPC_Dead),
								
								.start_l(start_l),
								.battle_l(battle_l),
								.win_l(win_l),
								.lose_l(lose_l)
								);
	 
	 // projectile belongs to player
	 projectile bullet(.Clk(Clk),
							.Reset(Reset_h || Soft_Reset_h),
							.frame_clk(VGA_VS),
							.Proj_X_Center(Player_X_curr), // Shooter's Center
							.Proj_Y_Center(Player_Y_curr),
							.Proj_X_Step(Proj_X_Speed),
							
							.Proj_X_Curr_Pos(Proj_X_curr),
							.Proj_Y_Curr_Pos(Proj_Y_curr),
							
							.activate(Shoot_h),
							.contact(bullet_contact),
							.DrawX(DrawX),
							.DrawY(DrawY),		// Current pixel coordinates
							.is_proj(is_proj)			// Whether pixel belongs to projectile or other
							);
							
	 hitbox bullet_npc(.Obj_X(Proj_X_curr),
							.Obj_Y(Proj_Y_curr),
							.Target_X(NPC_X_curr),
							.Target_Y(NPC_Y_curr),
							.Coverage(NPC_X_Size),
							.contact(bullet_contact));
												
    // Which signal should be frame_clk? VGA_VS
    player player_instance(.Clk(Clk),
								.Reset(Reset_h || Soft_Reset_h),
								.frame_clk(VGA_VS),
								.Player_X_Init(Player_X_Init),
								.Player_Y_Init(Player_Y_Init),
								
								.Player_X_Curr_Pos(Player_X_curr),
								.Player_Y_Curr_Pos(Player_Y_curr),
								.Player_X_Size(Player_X_Size),
								.Enemy_X_Curr_Pos(NPC_X_curr),
								.Enemy_Y_Curr_Pos(NPC_Y_curr),
								.Enemy_X_Size(NPC_X_Size),
								// controls
								.Up(Player_Up),
								.Left(Player_Left),
								.Right(Player_Right),
								
								.keycode(keycode),
								.DrawX(DrawX),
								.DrawY(DrawY),
								
								.sprite_size_x(sprite_size_x),
								.Player_RAM_addr(Player_RAM_addr),
								.is_player(is_player));
								
	 npc npc_instance(.Clk(Clk),
								.Reset(Reset_h || Soft_Reset_h),
								.frame_clk(VGA_VS),
								.NPC_X_Init(NPC_X_Init),
								.NPC_Y_Init(NPC_Y_Init),
								
								.NPC_X_Curr_Pos(NPC_X_curr),
								.NPC_Y_Curr_Pos(NPC_Y_curr),
								.NPC_X_Size(NPC_X_Size),
								.Enemy_X_Curr_Pos(Player_X_curr),
								.Enemy_Y_Curr_Pos(Player_Y_curr),
								.Enemy_X_Size(Player_X_Size),
								// controls
								.Up(NPC_Up_h),
								.Left(NPC_Left),
								.Right(NPC_Right),
								
								.keycode(keycode),
								.DrawX(DrawX),
								.DrawY(DrawY),
								
								.sprite_size_x(sprite_size_x),
								.NPC_RAM_addr(NPC_RAM_addr),
								.is_npc(is_npc));
	 
	 // coloring for character
	 char_frameRAM colors(.Player_address(Player_RAM_addr),
								.NPC_address(NPC_RAM_addr),
								.sprite_size_x(sprite_size_x),
								.player_pixel_on(player_pixel_on),
								.npc_pixel_on(npc_pixel_on),
								.Player_pixel(player_pixel),
								.NPC_pixel(npc_pixel));
	 
    color_mapper color_instance(	.Clk(Clk),
											.is_player(is_player),
											.is_npc(is_npc),
											.is_proj(is_proj),
											// stage
											.start_l(start_l),
											.battle_l(battle_l),
											.win_l(win_l),
											.lose_l(lose_l),
											
											.player_pixel_on(player_pixel_on),
											.player_pixel(player_pixel),
											.npc_pixel_on(npc_pixel_on),
											.npc_pixel(npc_pixel),
											
											.DrawX(DrawX),
											.DrawY(DrawY),
											.VGA_R(VGA_R),
											.VGA_G(VGA_G),
											.VGA_B(VGA_B));
											
   // Display keycode on hex display
   HexDriver hex_inst_0 (keycode[3:0], HEX0);
   HexDriver hex_inst_1 (keycode[7:4], HEX1);
	 
	// debug counter
    
endmodule
