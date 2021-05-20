`timescale 1ns / 1ps


module sim (
	
);

reg sys_clk = 0;
reg reset;
wire RGB0; 
wire RGB1; 
wire RGB2;

always	#(41.66)	sys_clk	<=	~sys_clk;
	
initial begin
	wait(sys_clk);
	wait(~sys_clk);
	reset = 1;
	wait(~sys_clk);
	wait(sys_clk);
	wait(~sys_clk);
	wait(sys_clk);
	wait(~sys_clk);
	wait(sys_clk);
	wait(~sys_clk);
	wait(sys_clk);
	wait(~sys_clk);
	reset = 0;
	#10000;
	//sw = 2;
	#10;
	//sw = 0;
	#100000;
	$finish;
end

wire [7:0]io_addr;
wire [7:0]io_out;
wire io_write;
wire [7:0]io_in;
wire io_read;
wire io_rst;


wire [2:0]led;

arduFPGA # (
	.DEBUG("TRUE")
	) ardyFPGA_inst (
	.rst_i(reset),
	.clk_i(sys_clk),
	.led(led)
	);
	
assign {RGB2, RGB1, RGB0} = ~led;

endmodule