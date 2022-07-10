//-------------------------------------------------------------------------------------------------
module zxd
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock50,

	output wire        VGA_VS,
   output wire        VGA_HS,
	output wire[ 5:0]  VGA_R,
  	output wire[ 5:0]  VGA_G,
	output wire[ 5:0]  VGA_B,

	inout  wire       ps2kCk,
	inout  wire       ps2kDQ,

	output wire       sdcCs,
	output wire       sdcCk,
	output wire       sdcMosi,
	input  wire       sdcMiso,
	
   output wire       joyS,
	output wire       joyCk,
	output wire       joyLd,
	input  wire       joyD,

	output wire       sramWe,
	output wire       sramOe,
	output wire       sramUb,
	output wire       sramLb,
	
	inout  wire[15:8] sramDQ,
	output wire[20:0] sramA,
   output wire       AUDIO_L,
	output wire       AUDIO_R,
	output wire       led
);

//-------------------------------------------------------------------------------------------------

wire clk_sys;

clock clock
( .CLK_IN1 (clock50),
  .RESET   (1'b0),
  .CLK_OUT1(clk_sys),
  .LOCKED  (pll_locked)
);

reg ce_10m7 = 0;
reg ce_5m3 = 0;
reg [1:0] div;

always @(posedge clk_sys) begin
	div <= div+1'd1;
	ce_10m7 <= !div[0];
	ce_5m3  <= !div[1:0];
end
//------------------------------------------------------------------------------------------------

wire [7:0] joy_0, joy_1;
assign joyS=hsync;

joystick Joystick
(
   .clock (clk_sys),
	.ce    (ce_10m7),
	.joy1  (joy_0),
	.joy2  (joy_1),
	.joyS  (),
	.joyCk (joyCk),
	.joyLd (joyLd),
	.joyD  (joyD)
	
);

//-------------------------------------------------------------------------------------------------

wire SPI_SCK = sdcCk;
wire SPI_SS2;
wire SPI_SS3;
wire SPI_SS4;
wire CONF_DATA_0;
wire SPI_DO;
wire SPI_DI;

wire kbiCk = ps2kCk;
wire kbiDQ = ps2kDQ;
wire kboCk; assign ps2kCk = kboCk ? 1'bZ : kboCk;
wire kboDQ; assign ps2kDQ = kboDQ ? 1'bZ : kboDQ;

substitute_mcu #(.sysclk_frequency(214)) controller
(
	.clk          (clk_sys),
	.reset_in     (1'b1   ),
	.reset_out    (       ),
	.spi_cs       (sdcCs  ),
	.spi_clk      (sdcCk  ),
	.spi_mosi     (sdcMosi),
	.spi_miso     (sdcMiso),
	.spi_req      (       ),
	.spi_ack      (1'b1   ),
	.spi_ss2      (SPI_SS2 ),
	.spi_ss3      (SPI_SS3 ),
	.spi_ss4      (SPI_SS4 ),
	.conf_data0   (CONF_DATA_0),
	.spi_toguest  (SPI_DO),
	.spi_fromguest(SPI_DI),
	.ps2k_clk_in  (kbiCk  ),
	.ps2k_dat_in  (kbiDQ  ),
	.ps2k_clk_out (kboCk  ),
	.ps2k_dat_out (kboDQ  ),
	.ps2m_clk_in  (1'b1   ),
	.ps2m_dat_in  (1'b1   ),
	.ps2m_clk_out (       ),
	.ps2m_dat_out (       ),
	.joy1         (~joy_0 ),
	.joy2         (~joy_1 ),
	.joy3         (8'hFF  ),
	.joy4         (8'hFF  ),
	.buttons      (8'hFF  ),
	.rxd          (1'b0   ),
	.txd          (       ),
	.intercept    (       ),
	.c64_keys     (64'hFFFFFFFF)
);


//-------------------------------------------------------------------------------------------------
parameter CONF_STR = {
	"Coleco;;",
	"F,COLBINROM,Load Cart;",
	"F,SG ,Load SG-1000;",
	"O79,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%;",
	"O3,Joysticks swap,No,Yes;",
	"O45,RAM Size,1KB,8KB,SGM;",
	"T0,Reset ColecoVision;",
	"T1,Reset ZxDOS+;",
	"V,V1.0;"
};

wire[63:0] status;
wire scandoubler_disable;
wire ypbpr;
wire [31:0] joy0, joy1;
wire  pressed ;
wire [7:0] code;
wire state;
assign joy0={joy_0[7:4],joy_0[0],joy_0[1],joy_0[2],joy_0[3]};
assign joy1={joy_1[7:4],joy_1[0],joy_1[1],joy_1[2],joy_1[3]};


user_io #(.STRLEN(1512>>3), .SD_IMAGES(1)) user_io
(
	.conf_str      (CONF_STR),
	.conf_chr      (        ),
	.conf_addr     (        ),
	.clk_sys       (clk_sys ),
	.clk_sd        (clk_sys ),
	.SPI_CLK       (SPI_SCK   ),
	.SPI_SS_IO     (CONF_DATA_0 ),
	.SPI_MOSI      (SPI_DO ),
	.SPI_MISO      (SPI_DI ),
	.status        (status  ),
	.buttons       (),
	.switches      (),
	.key_code      (code),
	.key_strobe    (state),
	.key_pressed   (pressed),
	.key_extended  (),
	.sd_rd         (),
	.sd_wr         (),
	.sd_sdhc       (),
	.sd_ack        (),
	.sd_conf       (),
	.sd_lba        (),
	.sd_ack_conf   (),
	.sd_buff_addr   (),
	.sd_din        (),
	.sd_dout       (),
	.sd_din_strobe (),
	.sd_dout_strobe(),
	.img_size      (),
	.img_mounted   (),
	.mouse_x       (),
	.mouse_y       (),
	.mouse_z       (),
	.mouse_idx     (),
	.mouse_flags   (),
	.mouse_strobe  (),
	.serial_data   (8'd0),
	.serial_strobe (1'd0),
	.rtc           (),
	.ypbpr         (ypbpr),
	.no_csync      (),
	.core_mod      (),
	.joystick_0    (),
	.joystick_1    (),
	.joystick_2    (),
	.joystick_3    (),
	.joystick_4    (),
	.ps2_kbd_clk   (),
	.ps2_kbd_data  (),
	.ps2_kbd_clk_i (),
	.ps2_kbd_data_i(),
	.ps2_mouse_clk (),
	.ps2_mouse_data(),
	.ps2_mouse_clk_i(),
	.ps2_mouse_data_i(),
	.joystick_analog_0(),
	.joystick_analog_1(),
	.scandoubler_disable(scandoubler_disable)
);

wire       ioctl_download;
wire       ioctl_wr;
wire[24:0] ioctl_addr;
wire[ 7:0] ioctl_dout;
wire[ 7:0] ioctl_index; 

data_io data_io
(
	.clk_sys       (clk_sys ),
	.clkref_n      (1'b0    ),
	.SPI_SCK       (SPI_SCK   ),
	.SPI_SS2       (SPI_SS2  ),
	.SPI_SS4       (SPI_SS4  ),
	.SPI_DI        (SPI_DO ),
	.SPI_DO        (SPI_DI ),
	.ioctl_index   (ioctl_index     ),
	.ioctl_upload  (        ),
	.ioctl_download(ioctl_download  ),
	.ioctl_wr      (ioctl_wr        ),
	.ioctl_addr    (ioctl_addr      ),
	.ioctl_din     (                ),
	.ioctl_dout    (ioctl_dout      ),
	.ioctl_fileext (                 ),
	.ioctl_filesize(                 )
);
/////////////////  RESET  /////////////////////////

wire keyb_reset = (ctrl&alt&del);

reg reset;
always @(posedge clk_sys) begin : reset_soft
   reg [1:0] old_mem;
	old_mem <= status[5:4];
	reset <= (status[0] | old_mem != status[5:4] | keyb_reset | ioctl_download);
end

wire hard_reset = status[1]|(ctrl&alt&bs);

multiboot #(.ADDR(24'hB0000)) Multiboot
(
	.clock(ce_10m7),
	.boot(hard_reset)
);

////////////////  Console  ////////////////////////

wire [13:0] audio;
assign DAC_L = {audio,2'd0};
assign DAC_R = {audio,2'd0};

dac #(14) dac_l (
   .clk_i        (clk_sys),
   .res_n_i      (1'b1      ),
   .dac_i        (audio  ),
   .dac_o        (AUDIO_L)
);

dac #(14) dac_r (
   .clk_i        (clk_sys),
   .res_n_i      (1'b1      ),
   .dac_i        (audio  ),
   .dac_o        (AUDIO_R)
);
/////////////////  Memory  ////////////////////////

wire [12:0] bios_a;
wire  [7:0] bios_d;

rom #(.KB(8), .FN("bios.hex")) Rom
(
	.clock  (clk_sys),
	.ce     (1'b1),
	.address(bios_a),
	.q      (bios_d)
);

wire [14:0] cpu_ram_a;
wire        ram_we_n, ram_ce_n;
wire  [7:0] ram_di;
wire  [7:0] ram_do;

wire [14:0] ram_a = (extram)            ? cpu_ram_a       :
                    (status[5:4] == 1)  ? cpu_ram_a[12:0] : // 8k
                    (status[5:4] == 0)  ? cpu_ram_a[9:0]  : // 1k
                    (sg1000)            ? cpu_ram_a[12:0] : // SGM means 8k on SG1000
                                          cpu_ram_a;        // SGM/32k

ram #(32) ram   
(
	.clock(clk_sys),
	.a(ram_a),
	.ce (1'b1),
	.we(ce_10m7 & ~(ram_we_n | ram_ce_n)),
	.d(ram_do),
	.q(ram_di)
);

wire [13:0] vram_a;
wire        vram_we;
wire  [7:0] vram_di;
wire  [7:0] vram_do;

ram #(16) vram
(
	.clock(clk_sys),
	.a    (vram_a),
   .ce   (1'b1),	
	.we   (vram_we),
	.d    (vram_do),
	.q    (vram_di)
);

wire [19:0] cart_a;
wire  [7:0] cart_d = sramDQ;;
wire        cart_rd;

reg [5:0] cart_pages;
always @(posedge clk_sys) if(ioctl_wr) cart_pages <= ioctl_addr[19:14];


//-------------------------------------------------------------------------------------------------
reg sg1000 = 0;
reg extram = 0;
always @(posedge clk_sys) begin
	if(ioctl_wr) begin
		if(!ioctl_addr) begin
			extram <= 0;
			sg1000 <= (ioctl_index[4:0] == 2);
		end
		if(ioctl_addr[24:13] == 1 && sg1000) extram <= (!ioctl_addr[12:0] | extram) & &ioctl_dout; // 2000-3FFF on SG-1000
	end
end

//-------------------------------------------------------------------------------------------------

wire [1:0] ctrl_p1;
wire [1:0] ctrl_p2;
wire [1:0] ctrl_p3;
wire [1:0] ctrl_p4;
wire [1:0] ctrl_p5;
reg  [1:0] ctrl_p6;
wire [1:0] ctrl_p7 = 2'b11;
wire [1:0] ctrl_p8;
wire [1:0] ctrl_p9 = 2'b11;

wire [7:0] R,G,B;
wire hblank, vblank;
wire hsync, vsync;

wire [31:0] joya = status[3] ? joy1 : joy0;
wire [31:0] joyb = status[3] ? joy0 : joy1;

cv_console console
(
	.clk_i(clk_sys),
	.clk_en_10m7_i(ce_10m7),
	.reset_n_i(~reset),
	.por_n_o(),
	.sg1000(sg1000),
	.dahjeeA_i(extram),

	.ctrl_p1_i(ctrl_p1),
	.ctrl_p2_i(ctrl_p2),
	.ctrl_p3_i(ctrl_p3),
	.ctrl_p4_i(ctrl_p4),
	.ctrl_p5_o(ctrl_p5),
	.ctrl_p6_i(ctrl_p6),
	.ctrl_p7_i(ctrl_p7),
	.ctrl_p8_o(ctrl_p8),
	.ctrl_p9_i(ctrl_p9),
	.joy0_i(~{|joya[19:6], 1'b0, joya[5:0]}),
	.joy1_i(~{|joyb[19:6], 1'b0, joyb[5:0]}),

	.bios_rom_a_o(bios_a),
	.bios_rom_d_i(bios_d),

	.cpu_ram_a_o(cpu_ram_a),
	.cpu_ram_we_n_o(ram_we_n),
	.cpu_ram_ce_n_o(ram_ce_n),
	.cpu_ram_d_i(ram_di),
	.cpu_ram_d_o(ram_do),

	.vram_a_o(vram_a),
	.vram_we_o(vram_we),
	.vram_d_o(vram_do),
	.vram_d_i(vram_di),

	.cart_pages_i(cart_pages),
	.cart_a_o(cart_a),
	.cart_d_i(cart_d),
	.cart_rd(cart_rd),

	.rgb_r_o(R),
	.rgb_g_o(G),
	.rgb_b_o(B),
	.hsync_n_o(hsync),
	.vsync_n_o(vsync),

	.audio_o(audio)
);

//-------------------------------------------------------------------------------------------------

assign sramUb = 1'b0;
assign sramLb = 1'b1;
assign sramOe = 1'b0;
assign sramWe = !ioctl_wr;
assign sramDQ = sramWe ? 8'bZ : ioctl_dout;
assign sramA = ioctl_download ? ioctl_addr : cart_a;

//-------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------

wire[2:0] border = 3'd0;


//-------------------------------------------------------------------------------------------------



mist_video #(.OSD_X_OFFSET(10), .OSD_Y_OFFSET(10), .OSD_COLOR(4)) mist_video(
	.clk_sys      (clk_sys   ),
	.SPI_SCK      (SPI_SCK     ),
	.SPI_SS3      (SPI_SS3    ),
	.SPI_DI       (SPI_DO   ),
	.R            (R[7:2]    ),
	.G            (G[7:2]    ),
	.B            (B[7:2]    ),
	.HSync        (hsync     ),
	.VSync        (vsync     ),
	.VGA_R        (VGA_R     ),
	.VGA_G        (VGA_G     ),
	.VGA_B        (VGA_B     ),
	.VGA_VS       (VGA_VS    ),
	.VGA_HS       (VGA_HS    ),
	.ce_divider   (1'b0       ),
	.scandoubler_disable  (scandoubler_disable	),
	.scanlines    (forced_scandoubler ? 2'b00 : {status[9:7] == 3, status[9:7] == 2}),
	.no_csync     (           ),
	
	.ypbpr        (ypbpr      )
	);


//-------------------------------------------------------------------------------------------------

//////////////// Keypad emulation (by Alan Steremberg) ///////


always @(posedge clk_sys) begin : keypad_emulation
	reg old_state;
	old_state <= state;

	if(old_state != state) begin
		casex(code)

			'hX16: btn_1     <= pressed; // 1
			'hX1E: btn_2     <= pressed; // 2
			'hX26: btn_3     <= pressed; // 3
			'hX25: btn_4     <= pressed; // 4
			'hX2E: btn_5     <= pressed; // 5
			'hX36: btn_6     <= pressed; // 6
			'hX3D: btn_7     <= pressed; // 7
			'hX3E: btn_8     <= pressed; // 8
			'hX46: btn_9     <= pressed; // 9
			'hX45: btn_0     <= pressed; // 0

/*			'hX69: btn_1     <= pressed; // 1
			'hX72: btn_2     <= pressed; // 2
			'hX7A: btn_3     <= pressed; // 3
			'hX6B: btn_4     <= pressed; // 4
			'hX73: btn_5     <= pressed; // 5
			'hX74: btn_6     <= pressed; // 6
			'hX6C: btn_7     <= pressed; // 7
			'hX75: btn_8     <= pressed; // 8
			'hX7D: btn_9     <= pressed; // 9
			'hX70: btn_0     <= pressed; // 0
*/
			'hX7C: btn_star  <= pressed; // *
			'hX59: btn_shift <= pressed; // Right Shift
			'hX12: btn_shift <= pressed; // Left Shift
			'hX7B: btn_minus <= pressed; // - on keypad
			
			'hX74: btn_right <= pressed; // ->
			'hX6B: btn_left  <= pressed; // <- 
			'hX75: btn_up    <= pressed; // ^ 
			'hX72: btn_down  <= pressed; // v 
			'hX1A: btn_fire1  <= pressed; // Z
			'hX22: btn_fire2  <= pressed; // X
			
	      'hX71: del       <= pressed;
		   'hX11: alt       <= pressed;
		   'hX14: ctrl      <= pressed;
         'hX66: bs        <= pressed;
		endcase
	end
end

reg bs    = 0;
reg del   = 0;
reg alt   = 0;
reg ctrl  = 0;

reg btn_1 = 0;
reg btn_2 = 0;
reg btn_3 = 0;
reg btn_4 = 0;
reg btn_5 = 0;
reg btn_6 = 0;
reg btn_7 = 0;
reg btn_8 = 0;
reg btn_9 = 0;
reg btn_0 = 0;

reg btn_star = 0;
reg btn_shift = 0;
reg btn_minus = 0;

reg btn_right = 0;
reg btn_left  = 0;
reg btn_up    = 0;
reg btn_down  = 0;
reg btn_fire1  = 0;
reg btn_fire2  = 0;


//-------------------------------------------------------------------------------------------------

wire [0:19] keypad0 = {joya[8],joya[9],joya[10],joya[11],joya[12],joya[13],joya[14],joya[15],joya[16],joya[17],joya[6],joya[7],joya[18],joya[19],joya[3],joya[2],joya[1],joya[0],joya[4],joya[5]};
wire [0:19] keypad1 = {joyb[8],joyb[9],joyb[10],joyb[11],joyb[12],joyb[13],joyb[14],joyb[15],joyb[16],joyb[17],joyb[6],joyb[7],joyb[18],joyb[19],joyb[3],joyb[2],joyb[1],joyb[0],joyb[4],joyb[5]};
wire [0:19] keyboardemu = { btn_0, btn_1, btn_2, btn_3, btn_4, btn_5, btn_6, btn_7, btn_8, btn_9, btn_star | (btn_8&btn_shift), btn_minus | (btn_shift & btn_3), 8'b0};
wire [0:19] keypad[2:0];
assign keypad[0] = keypad0|keyboardemu;
assign keypad[1] = keypad1|keyboardemu;

reg [3:0] ctrl1[1:0] ;

assign {ctrl_p1[0],ctrl_p2[0],ctrl_p3[0],ctrl_p4[0]} = ctrl1[0];
assign {ctrl_p1[1],ctrl_p2[1],ctrl_p3[1],ctrl_p4[1]} = ctrl1[1];

localparam cv_key_0_c        = 4'b0011;
localparam cv_key_1_c        = 4'b1110;
localparam cv_key_2_c        = 4'b1101;
localparam cv_key_3_c        = 4'b0110;
localparam cv_key_4_c        = 4'b0001;
localparam cv_key_5_c        = 4'b1001;
localparam cv_key_6_c        = 4'b0111;
localparam cv_key_7_c        = 4'b1100;
localparam cv_key_8_c        = 4'b1000;
localparam cv_key_9_c        = 4'b1011;
localparam cv_key_asterisk_c = 4'b1010;
localparam cv_key_number_c   = 4'b0101;
localparam cv_key_pt_c       = 4'b0100;
localparam cv_key_bt_c       = 4'b0010;
localparam cv_key_none_c     = 4'b1111;

generate 
	genvar i;
	for (i = 0; i < 2; i=i+1) begin : ctl
		always @* begin : ctl_block
		   reg [3:0] ctl1, ctl2;
         reg p61,p62;

			ctl1 = 4'b1111;
			ctl2 = 4'b1111;
			p61 = 1;
			p62 = 1;

			if (~ctrl_p5[i]) begin
				casex(keypad[i][0:13]) 
					'b1xxxxxxxxxxxxx: ctl1 = cv_key_0_c;
					'b01xxxxxxxxxxxx: ctl1 = cv_key_1_c;
					'b001xxxxxxxxxxx: ctl1 = cv_key_2_c;
					'b0001xxxxxxxxxx: ctl1 = cv_key_3_c;
					'b00001xxxxxxxxx: ctl1 = cv_key_4_c;
					'b000001xxxxxxxx: ctl1 = cv_key_5_c;
					'b0000001xxxxxxx: ctl1 = cv_key_6_c;
					'b00000001xxxxxx: ctl1 = cv_key_7_c;
					'b000000001xxxxx: ctl1 = cv_key_8_c;
					'b0000000001xxxx: ctl1 = cv_key_9_c;
					'b00000000001xxx: ctl1 = cv_key_asterisk_c;
					'b000000000001xx: ctl1 = cv_key_number_c;
					'b0000000000001x: ctl1 = cv_key_pt_c;
					'b00000000000001: ctl1 = cv_key_bt_c;
					'b00000000000000: ctl1 = cv_key_none_c;
				endcase
				p61 = ~keypad[i][19]; // button 2
			end
      
		   if (~ctrl_p8[i]) begin
				ctl2 = ~keypad[i][14:17];
				p62  = ~keypad[i][18];  // button 1
			end
			
			ctrl1[i] = ctl1 & ctl2;
			ctrl_p6[i] = p61 & p62; 
		end
	end
endgenerate


//-------------------------------------------------------------------------------------------------

assign led =ioctl_download;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
