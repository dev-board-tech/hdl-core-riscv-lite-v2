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


`undef ADDR_BUS_WIDTH
`define ADDR_BUS_WIDTH			16

`undef ROM_ADDR_WIDTH
`define ROM_ADDR_WIDTH			12

`undef RAM_ADDR_WIDTH
`define RAM_ADDR_WIDTH			12

`undef C_EXTENSION
`define C_EXTENSION	"FALSE"
`undef SYNCHRONOUS_ROM
`define SYNCHRONOUS_ROM "TRUE"
`undef SYNCHRONOUS_RAM
`define SYNCHRONOUS_RAM "TRUE"


module arduFPGA # (
	parameter DEBUG = "FALSE"
	) (
	input rst_i,
	input clk_i,
	output reg[2:0]led
	);

wire [`ADDR_BUS_WIDTH - 1:0]pgm_addr;
wire [31:0]pgm_data;
wire [`ADDR_BUS_WIDTH - 1:0]data_addr;
wire [31:0]data_out;
wire data_wr_w;
wire data_wr_h;
wire data_wr_b;
wire [31:0]data_in;
wire data_rd_w;
wire data_rd_h;
wire data_rd_b;

wire data_en = data_addr[`ADDR_BUS_WIDTH - 1: `ADDR_BUS_WIDTH - 2] == 2'b01;
wire pgm_en = data_addr[`ADDR_BUS_WIDTH - 1];
wire io_en = ~pgm_en && ~data_en && |data_addr[`ADDR_BUS_WIDTH - 1:8];

wire rom_select;
wire ram_select;

wire int_sig;
wire int_ack;

always @(posedge clk_i)
begin
	if(rst_i)
	begin
		led <= 3'h00;
	end
	else if(data_wr_w & io_en)
	begin
		case(data_addr[3:2])
		2'h0: led <= data_out[7:0];
		2'h1: led <= led | data_out[7:0];
		2'h2: led <= led & ~data_out[7:0];
		endcase
	end
end

rtc #(
	.PERIOD_STATIC(16000),
	.CNT_SIZE(14)
)rtc_inst(
	.rst_i(rst_i),
	.clk_i(clk_i),
	.clk_cnt_i(clk_i),
	.top_i(),
	.int_o(int_sig),
	.int_ack_i(int_ack)
);

wire [31:0]rom_bus_out;
rom_dp # (
	.PLATFORM("XILINX"),
	.ADDR_BUS_LEN(`ROM_ADDR_WIDTH),
	.EXTENSION_C(`C_EXTENSION),
	.ROM_PATH("core1ROM_LightTest"),
	.SYNCHRONOUS_OUTPUT(`SYNCHRONOUS_ROM)
)rom_dp_inst(
	.clk(clk_i),
	.addr_p1(pgm_addr[`ROM_ADDR_WIDTH - 1 : 0]),
	.cs_p1(1'b1),
	.out_p1(pgm_data),
	.data_p1_rdy(),
	.addr_p2(data_addr[`ROM_ADDR_WIDTH - 1 : 0]),
	.cs_p2(pgm_en),
	.out_p2(rom_bus_out),
	.data_p2_rdy(rom_select)
);


wire [31:0]ram_bus_out;
ram # (
	.PLATFORM("XILINX"),
	.ADDR_BUS_LEN(`RAM_ADDR_WIDTH),
	.SYNCHRONOUS_OUTPUT(`SYNCHRONOUS_RAM)
)ram_inst(
	.clk(clk_i),
	.addr(data_addr[`RAM_ADDR_WIDTH - 1: 0]),
	.cs(data_en),
	.out(ram_bus_out),
	.data_rdy(ram_select),
	.in(data_out),
	.write_w(data_wr_w),
	.write_h(data_wr_h),
	.write_b(data_wr_b)
);


io_bus_dmux #(
	.NR_OF_BUSSES_IN(2),
	.BITS_PER_BUS(32),
	.USE_OR_METHOD("TRUE")
) io_bus_dmux_inst(
	.bus_in({ 
	//pioA_bus_out, 
	ram_bus_out,
	rom_bus_out
	}
),
	.bus_sel({
	ram_select,
	rom_select
	}),
	.bus_out(data_in)
);


risc_v # (
	.DEBUG(DEBUG),
	.PLATFORM("XILINX"),
	.SINGLE_BUS("TRUE"),
	.DATA_BUS_ALWAYS_CONNECTED("TRUE"),
	.ADDR_BUS_WIDTH(`ADDR_BUS_WIDTH),
	.RESET_VECTOR(16'h8000),
	.EXTENSION_M("FALSE"),
	.EXTENSION_MDIV("FALSE"),
	.EXTENSION_C(`C_EXTENSION),
	.WATCHDOG_CNT_WIDTH(0),
	.VECTOR_INT_TABLE_SIZE(1),
	.STALL_INPUT_LINES(0)
)risc_v_inst(
	.rst_i(rst_i),
	.clk_i(clk_i),
	.core_stall_i(),
	.pgm_addr_o(pgm_addr),
	.pgm_inst_i(pgm_data),
	.data_addr_o(data_addr),
	.data_o(data_out),
	.data_wr_w_o(data_wr_w),
	.data_wr_h_o(data_wr_h),
	.data_wr_b_o(data_wr_b),
	.data_wr_ack_i(),
	.data_i(data_in),
	.data_rd_w_o(data_rd_w),
	.data_rd_h_o(data_rd_h),
	.data_rd_b_o(data_rd_b),
	.data_rd_valid_i(),
	.int_sig_i(int_sig),
	.int_ack_o(int_ack),
	.int_en_o()
);

endmodule