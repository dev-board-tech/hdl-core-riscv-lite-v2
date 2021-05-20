/*
 * This IP is the the RISC-V32I instruction set core implementation.
 * 
 * Copyright (C) 2021  Iulian Gheorghiu (morgoth@devboard.tech)
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

module top (
	output RGB0, 
	output RGB1, 
	output RGB2, 
	output BUZ_L,
	output BUZ_G,
	output BUZ_R,
	output OLED_DC,
	output OLED_SS,
	output OLED_RST,
	output SCK,
	output MOSI,
	input MISO,
	input BTN_RIGHT,
	input BTN_LEFT,
	input BTN_UP,
	input BTN_DN,
	input BTN_BACK,
	input BTN_OK,
	input BTN_INTERRUPT,
	output DES_SS,
	output uSD_SS,
	input uSD_CD,
	output APP_SS,
	output VS_RST,
	output VS_xCS,
	output VS_xDCS,
	input VS_DREQ,

	output UART_TX,
	inout UART_RX,

	inout USBP,
	inout USBN
);

wire pll_locked;
reg [3:0]pll_locked_buf;
wire sys_clk;
wire sys_rst = ~pll_locked_buf[3];
wire pll_clk = sys_clk;
wire sys_clk_int;
reg [1:0]sys_clk_t;


always @ (posedge sys_clk)
begin
	pll_locked_buf <= {pll_locked_buf[2:0], pll_locked}; 
end

HSOSC
#(
  .CLKHF_DIV ("0b00")
) HSOSC_inst (
  .CLKHFPU (1'b1),  // I
  .CLKHFEN (1'b1),  // I
  .CLKHF   (clk)   // O
);
//synthesis ROUTE_THROUGH_FABRIC = 0;
// /* synthesis ROUTE_THROUGH_FABRIC= [0|1] */

PLL_DEV_48M PLL_inst(
	.ref_clk_i(clk),
	.bypass_i(1'b0),
	.rst_n_i(1'b1), 
	.lock_o(pll_locked), 
	.outcore_o(sys_clk_int), 
	.outglobal_o(sys_clk) 
);

wire [7:0]io_addr;
wire [7:0]io_out;
wire io_write;
wire [7:0]io_in;
wire io_read;
wire io_rst;


wire [2:0]led;

arduFPGA # (
	) ardyFPGA_inst (
	.rst_i(~pll_locked_buf[3]),
	.clk_i(sys_clk),
	.led(led)
	);

BB_OD LED_B_Inst (
  .T_N (1'b1),  // I
  .I   (~led[2]),  // I
  .O   (),  // O
  .B   (RGB2)   // IO
);
BB_OD LED_G_Inst (
  .T_N (1'b1),  // I
  .I   (~led[1]),  // I
  .O   (),  // O
  .B   (RGB1)   // IO
);
BB_OD LED_R_Inst (
  .T_N (1'b1),  // I
  .I   (~led[0]),  // I
  .O   (),  // O
  .B   (RGB0)   // IO
);
endmodule