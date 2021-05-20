`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2021 01:03:16 PM
// Design Name: 
// Module Name: sim
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


`timescale 1ns / 1ps

module sim(

    );

reg clk = 1;
reg rst = 0;
always	#(41.66)	clk	<=	~clk;
reg sw = 0;
wire [1:0]sw_ = {sw, rst};

initial begin
	wait(clk);
	wait(~clk);
	rst = 1;
	wait(~clk);
	wait(clk);
	wait(~clk);
	wait(clk);
	wait(~clk);
	wait(clk);
	wait(~clk);
	wait(clk);
	wait(~clk);
	rst = 0;
	#10000;
	//sw = 2;
	#10;
	//sw = 0;
	#100000;
	$finish;
end

top # (
	.DEBUG("TRUE")
) top_inst (
	.sys_clk_pin(clk),
	.LED(),
	.RGB0_Red(),
	.RGB0_Green(),
	.RGB0_Blue(),
	.BTN(sw_)
);
endmodule
