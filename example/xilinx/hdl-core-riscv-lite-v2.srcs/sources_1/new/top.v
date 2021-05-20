`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2021 01:05:00 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

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


module top # (
		parameter DEBUG = "FALSE"
)(
		input sys_clk_pin,
		output reg [1:0]LED,
		output reg RGB0_Red,
		output reg RGB0_Green,
		output reg RGB0_Blue,
		input [1:0]BTN
);

wire rst = BTN[0];
wire core_clk;
wire clkfb;
wire pll_locked;
reg sys_rst;
always @ (posedge core_clk) sys_rst <= pll_locked;

MMCME2_BASE #(
	.BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
	.CLKFBOUT_MULT_F(50.0),     // Multiply value for all CLKOUT (2.000-64.000).
	.CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (-360.000-360.000).
	.CLKIN1_PERIOD(83.33),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
	// CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
	.CLKOUT1_DIVIDE(1),
	.CLKOUT2_DIVIDE(1),
	.CLKOUT3_DIVIDE(1),
	.CLKOUT4_DIVIDE(1),
	.CLKOUT5_DIVIDE(1),
	.CLKOUT6_DIVIDE(1),
	.CLKOUT0_DIVIDE_F(5.0),    // Divide amount for CLKOUT0 (1.000-128.000).
	// CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
	.CLKOUT0_DUTY_CYCLE(0.5),
	.CLKOUT1_DUTY_CYCLE(0.5),
	.CLKOUT2_DUTY_CYCLE(0.5),
	.CLKOUT3_DUTY_CYCLE(0.5),
	.CLKOUT4_DUTY_CYCLE(0.5),
	.CLKOUT5_DUTY_CYCLE(0.5),
	.CLKOUT6_DUTY_CYCLE(0.5),
	// CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
	.CLKOUT0_PHASE(0.0),
	.CLKOUT1_PHASE(0.0),
	.CLKOUT2_PHASE(0.0),
	.CLKOUT3_PHASE(0.0),
	.CLKOUT4_PHASE(0.0),
	.CLKOUT5_PHASE(0.0),
	.CLKOUT6_PHASE(0.0),
	.CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
	.DIVCLK_DIVIDE(1),         // Master division value (1-106)
	.REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
	.STARTUP_WAIT("TRUE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
)
MMCME2_BASE_inst (
	// Clock Outputs: 1-bit (each) output: User configurable clock outputs
	.CLKOUT0(core_clk),     // 1-bit output: CLKOUT0
	.CLKOUT0B(),   // 1-bit output: Inverted CLKOUT0
	.CLKOUT1(),     // 1-bit output: CLKOUT1
	.CLKOUT1B(),   // 1-bit output: Inverted CLKOUT1
	.CLKOUT2(),     // 1-bit output: CLKOUT2
	.CLKOUT2B(),   // 1-bit output: Inverted CLKOUT2
	.CLKOUT3(),     // 1-bit output: CLKOUT3
	.CLKOUT3B(),   // 1-bit output: Inverted CLKOUT3
	.CLKOUT4(),     // 1-bit output: CLKOUT4
	.CLKOUT5(),     // 1-bit output: CLKOUT5
	.CLKOUT6(),     // 1-bit output: CLKOUT6
	// Feedback Clocks: 1-bit (each) output: Clock feedback ports
	.CLKFBOUT(clkfb),   // 1-bit output: Feedback clock
	.CLKFBOUTB(), // 1-bit output: Inverted CLKFBOUT
	// Status Ports: 1-bit (each) output: MMCM status ports
	.LOCKED(pll_locked),       // 1-bit output: LOCK
	// Clock Inputs: 1-bit (each) input: Clock input
	.CLKIN1(sys_clk_pin),       // 1-bit input: Clock
	// Control Ports: 1-bit (each) input: MMCM control ports
	.PWRDWN(),       // 1-bit input: Power-down
	.RST(rst),             // 1-bit input: Reset
	// Feedback Clocks: 1-bit (each) input: Clock feedback ports
	.CLKFBIN(clkfb)      // 1-bit input: Feedback clock
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


wire [31:0]pioA_bus_out = 0;//(data_rd_w & io_en & data_addr[12:0] == 11'h10) ? BTN : 32'h00000000;

always @(posedge core_clk)
begin
	if(~sys_rst | rst)
	begin
		{LED, RGB0_Red, RGB0_Green, RGB0_Blue} <= 8'h00;
	end
	else if(data_wr_w & io_en)
	begin
		case(data_addr[3:2])
		2'h0: {LED, RGB0_Red, RGB0_Green, RGB0_Blue} <= data_out[7:0];
		2'h1: {LED, RGB0_Red, RGB0_Green, RGB0_Blue} <= {LED, RGB0_Red, RGB0_Green, RGB0_Blue} | data_out[7:0];
		2'h2: {LED, RGB0_Red, RGB0_Green, RGB0_Blue} <= {LED, RGB0_Red, RGB0_Green, RGB0_Blue} & ~data_out[7:0];
		endcase
	end
end

rtc #(
	.PERIOD_STATIC(120000),
	.CNT_SIZE(17)
)rtc_inst(
	.rst_i(~sys_rst | rst),
	.clk_i(core_clk),
	.clk_cnt_i(core_clk),
	.top_i(),
	.int_o(int_sig),
	.int_ack_i(int_ack)
);


wire core_stall;
assign core_stall = 0;

wire [31:0]rom_bus_out;
rom_dp # (
	.PLATFORM("XILINX"),
	.ADDR_BUS_LEN(`ROM_ADDR_WIDTH),
	.EXTENSION_C(`C_EXTENSION),
	.ROM_PATH("core1ROM_LightTest"),
	.SYNCHRONOUS_OUTPUT(`SYNCHRONOUS_ROM)
)rom_dp_inst(
	.clk(core_clk),
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
	.clk(core_clk),
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
	)
	io_bus_dmux_inst(
	.bus_in({ 
	//pioA_bus_out, 
	ram_bus_out,
	rom_bus_out
	}),
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
	.rst_i(~sys_rst | rst),
	.clk_i(core_clk),
	.core_stall_i(1'b0),
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
