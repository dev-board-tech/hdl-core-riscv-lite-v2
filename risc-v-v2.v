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

`timescale 1ns / 1ps

`define IDLE_BUS_STATE		0

`include "risc-v-l-h.v"
/*
--------------------------------------------------------------------------
System registers in IO space
--------------------------------------------------------------------------
*/

`define REG_MSTATUS					(6'h00)	//Machine status register.
`define REG_MIE						(6'h01)	//Machine interrupt-enable register.
`define REG_RIP						(6'h02) //Return from interupt address.
`define REG_MSCRATCH				(6'h03)	//Scratch register for machine trap handlers.
`define REG_MEPC					(6'h04)	//Machine exception program counter.
`define REG_MCAUSE					(6'h05)	//Machine trap cause.
`define REG_MBADADDR				(6'h06)	//Machine bad address.

`define REG_MSTATUS_MIE_bp			3
`define REG_MSTATUS_HIE_bp			2
`define REG_MSTATUS_SIE_bp			1
`define REG_MSTATUS_UIE_bp			0

/*
 * Interrupt and priority encoder.
 */
module int_encoder # (
		parameter VECTOR_INT_TABLE_SIZE = 0
)(
		input rst,
		input [((VECTOR_INT_TABLE_SIZE == 0) ? 0 : VECTOR_INT_TABLE_SIZE-1):0]int_sig_in,
		output int_request,
		output reg[(VECTOR_INT_TABLE_SIZE ? (clogb2(VECTOR_INT_TABLE_SIZE) - 1) : 0)  : 0]int_vect
);
//  The following function calculates the address width based on specified data depth
function integer clogb2;
	input integer depth;
	for (clogb2=0; depth>0; clogb2=clogb2+1)
		depth = depth >> 1;
endfunction

integer j;
always @*
begin
	if(VECTOR_INT_TABLE_SIZE != 0)
	begin
		int_vect <= 0;
		for (j=VECTOR_INT_TABLE_SIZE-1; j>=0; j=j-1)
		if (int_sig_in[j]) 
			int_vect <= j+1;
	end
end

assign int_request = (int_vect != 0 && VECTOR_INT_TABLE_SIZE != 'h0);

endmodule
/*
 * !Interrupt and priority encoder.
 */


module risc_v #(
	parameter DEBUG = "FALSE",
	parameter PLATFORM = "XILINX",
	parameter SINGLE_BUS = "TRUE",
	parameter DATA_BUS_ALWAYS_CONNECTED = "TRUE",
	parameter ADDR_BUS_WIDTH = 16,
	parameter RESET_VECTOR = 16'h8000,
	parameter EXTENSION_C = "TRUE",
	parameter EXTENSION_M = "TRUE",
	parameter EXTENSION_MDIV = "FALSE",
	parameter WATCHDOG_CNT_WIDTH = 0,
	parameter VECTOR_INT_TABLE_SIZE = 0,
	parameter STALL_INPUT_LINES = 1
	)(
	input rst_i,
	input clk_i,
	input [STALL_INPUT_LINES - 1:0]core_stall_i,
	output [ADDR_BUS_WIDTH - 1:0]pgm_addr_o,
	input [31:0]pgm_inst_i,
	output reg [ADDR_BUS_WIDTH - 1:0]data_addr_o,
	output reg [31:0]data_o,
	output reg data_wr_w_o,
	output reg data_wr_h_o,
	output reg data_wr_b_o,
	input data_wr_ack_i,
	input [31:0]data_i,
	output reg data_rd_w_o,
	output reg data_rd_h_o,
	output reg data_rd_b_o,
	input data_rd_valid_i,
	input [(VECTOR_INT_TABLE_SIZE == 0 ? 0 : VECTOR_INT_TABLE_SIZE - 1):0]int_sig_i,
	output reg [(VECTOR_INT_TABLE_SIZE == 0 ? 0 : VECTOR_INT_TABLE_SIZE - 1):0]int_ack_o,
	output int_en_o
    );

reg [31:0]instruction_latch;
reg [1:0]stage_cnt;
reg [1:0]stage_cnt_del;
reg skip_execution;
reg skip_execution_del;
reg enter_interrupt;
reg after_reset;
reg [1:0]load_from_interrupt_stage_cnt;

wire [4:0]rs1a = SINGLE_BUS == "TRUE" ? data_i[19:15] : pgm_inst_i[19:15];
wire [31:0]rs1;
wire [4:0]rs2a = SINGLE_BUS == "TRUE" ? data_i[24:20] : pgm_inst_i[24:20];
wire [31:0]rs2;
wire [4:0]rda = instruction_latch[11:7];
wire [31:0]rd_alu;
reg [31:0]rd;
reg rdw;
reg [31:0]data_sysreg_int;
reg sysreg_rd;


wire rs1_eq_rs2;
wire rs1_lt_rs2;
wire rs1_ltu_rs2;

reg [ADDR_BUS_WIDTH - 1:0] PC;
assign pgm_addr_o = PC;
reg [ADDR_BUS_WIDTH - 1:0] pc_delayed_1;
reg [ADDR_BUS_WIDTH - 1:0]RIP; /* Return Interrupt Pointer */

reg [7:0]reg_mie;						//Machine interrupt-enable register.
reg [7:0]reg_mstatus;					//Machine status register.
reg [7:0]reg_mcause;					//Machine trap cause.
reg [ADDR_BUS_WIDTH - 1:0]reg_mscratch;	//Scratch register for machine trap handlers.

wire [ADDR_BUS_WIDTH - 1:0]PC_FOR_AUIPC_AND_REL_JMP = PC - 4;

assign int_en_o = reg_mstatus[`REG_MSTATUS_MIE_bp];
reg put_int_table_addr;

//  The following function calculates the address width based on specified data depth
function integer clogb2;
	input integer depth;
	for (clogb2=0; depth>0; clogb2=clogb2+1)
		depth = depth >> 1;
endfunction

always @ (posedge clk_i) begin
	
end

always @ (posedge clk_i) begin
	data_sysreg_int <= data_i;
	sysreg_rd <= 1'b0;
    if(~rst_i)
    begin
        if(~|data_addr_o[ADDR_BUS_WIDTH - 1:8] && data_rd_w_o)
        begin
    		sysreg_rd <= 1'b1;
            case(data_addr_o[7:2])
            `REG_MCAUSE: data_sysreg_int <= reg_mcause;
            `REG_RIP: data_sysreg_int <= RIP;
            `REG_MSTATUS: data_sysreg_int <= reg_mstatus;
            endcase
        end
    end
end

wire int_request;
wire [(VECTOR_INT_TABLE_SIZE ? (clogb2(VECTOR_INT_TABLE_SIZE) - 1) : 0)  : 0]current_int_vect_request;

int_encoder # (
	.VECTOR_INT_TABLE_SIZE(VECTOR_INT_TABLE_SIZE)
)int_encoder_inst(
	.rst(rst),
	.int_sig_in(int_sig_i),
	.int_request(int_request),
	.int_vect(current_int_vect_request)
);

always @ * begin
	if(SINGLE_BUS == "TRUE") begin
		data_addr_o = PC;
	end else begin
		if(DATA_BUS_ALWAYS_CONNECTED != "TRUE") begin
			data_addr_o = {ADDR_BUS_WIDTH{1'b`IDLE_BUS_STATE}};
		end
	end
	rd = rd_alu;
	rdw = 1'b0;
	data_wr_w_o = 1'b0;
	data_wr_h_o = 1'b0;
	data_wr_b_o = 1'b0;
	if(DATA_BUS_ALWAYS_CONNECTED == "TRUE") begin
		data_o = rs2;
	end else begin
		data_o = 32'b`IDLE_BUS_STATE;
	end
	data_rd_w_o = 1'b0;
	data_rd_h_o = 1'b0;
	data_rd_b_o = 1'b0;
/* ram_addr_out */
	casex({enter_interrupt, put_int_table_addr, skip_execution_del, stage_cnt, instruction_latch})
		{1'b0, 1'b0, 1'd0, 2'd1, `RISC_V_ALU_INST_EXT_I_LOAD}: begin
			data_addr_o = rs1 + {{21{instruction_latch[31]}}, instruction_latch[30:20]};
		end
		{1'b0, 1'b0, 1'd0, SINGLE_BUS == "TRUE" ? 2'd1 : 2'd0, `RISC_V_ALU_INST_EXT_I_STORE}: begin
			data_addr_o = rs1 + {{21{instruction_latch[31]}}, instruction_latch[30:25], instruction_latch[11:7]};
		end
	endcase
/* data_read */
	casex({enter_interrupt, skip_execution_del, stage_cnt_del, instruction_latch})
		{1'b0, 1'b0, 2'd0, `RISC_V_ALU_INST_EXT_I_LOAD}: begin
			if(DEBUG == "TRUE") begin
				case(instruction_latch[14:12])
					{`RISC_V_ALU_INST_EXT_I_LB},
					{`RISC_V_ALU_INST_EXT_I_LBU}: data_rd_b_o = 1'b1;
					{`RISC_V_ALU_INST_EXT_I_LH},
					{`RISC_V_ALU_INST_EXT_I_LHU}: data_rd_h_o = 1'b1;
					{`RISC_V_ALU_INST_EXT_I_LW}: data_rd_w_o = 1'b1;
				endcase
			end
		end
		{1'b0, 1'b0, 2'd1, `RISC_V_ALU_INST_EXT_I_LOAD}: begin
			case(instruction_latch[14:12])
				{`RISC_V_ALU_INST_EXT_I_LB}: rd = sysreg_rd ? {{24{data_sysreg_int[7]}}, data_sysreg_int[7:0]} : {{24{data_i[7]}}, data_i[7:0]};
				{`RISC_V_ALU_INST_EXT_I_LBU}: rd = sysreg_rd ? {24'h000000, data_sysreg_int[7:0]} : {24'h000000, data_i[7:0]};
				{`RISC_V_ALU_INST_EXT_I_LH}: rd = sysreg_rd ? {{16{data_sysreg_int[15]}}, data_sysreg_int[15:0]} : {{16{data_i[15]}}, data_i[15:0]};
				{`RISC_V_ALU_INST_EXT_I_LHU}: rd = sysreg_rd ? {16'h0000, data_sysreg_int[15:0]} : {16'h0000, data_i[15:0]};
				{`RISC_V_ALU_INST_EXT_I_LW}: rd = sysreg_rd ? data_sysreg_int : data_i;
			endcase
			rdw = 1'b1;
		end
		{1'b0, 1'b0, 2'bx0, `RISC_V_ALU_INST_LUI}: begin
			rd = {instruction_latch[31:12], 12'h000};
			rdw = 1'b1;
		end
		{1'b0, 1'b0, 2'bx0, `RISC_V_ALU_INST_AUIPC}: begin
			rd = pc_delayed_1 + {instruction_latch[31:12], 12'h000} - 4;
			rdw = 1'b1;
		end
		{1'b0, 1'b0, 2'bx0, `RISC_V_ALU_INST_JAL},
		{1'b0, 1'b0, 2'bx0, `RISC_V_ALU_INST_JALR}: begin
			rd = pc_delayed_1;
			rdw = 1'b1;
		end
		{1'b0, 1'b0, 2'd0, `RISC_V_ALU_INST_EXT_I_R},
		{1'b0, 1'b0, 2'd0, `RISC_V_ALU_INST_EXT_I_I},
		{1'b0, 1'b0, 2'd0, `RISC_V_ALU_INST_EXT_I_R_W},
		{1'b0, 1'b0, 2'd0, `RISC_V_ALU_INST_EXT_M_R}: rdw = 1'b1;

	endcase
/* data_write */
	casex({enter_interrupt, skip_execution_del, stage_cnt, instruction_latch})
		{1'b0, 1'b0, SINGLE_BUS == "TRUE" ? 2'd1 : 2'dx, `RISC_V_ALU_INST_EXT_I_STORE}: begin
			if(DATA_BUS_ALWAYS_CONNECTED != "TRUE") begin
				data_o = rs2;
			end
			case(instruction_latch[13:12])
				`RISC_V_ALU_INST_EXT_I_SB: data_wr_b_o = 1'b1;
				`RISC_V_ALU_INST_EXT_I_SH: data_wr_h_o = 1'b1;
				`RISC_V_ALU_INST_EXT_I_SW: data_wr_w_o = 1'b1;
			endcase
		end
	endcase
end

always @ (posedge clk_i) begin
	skip_execution_del <= skip_execution;
	pc_delayed_1 <= PC;
	stage_cnt_del <= stage_cnt;
	stage_cnt <= 1'd0;
	skip_execution <= 1'b0;
	enter_interrupt = 1'b0;
	int_ack_o <= 'b0;
	put_int_table_addr <= 1'b0;
    if(rst_i) begin
		PC <= RESET_VECTOR;
		instruction_latch = 32'h0;
		after_reset <= 1'b1;
		load_from_interrupt_stage_cnt <= 2'b00;
		reg_mstatus[`REG_MSTATUS_MIE_bp] <= 1'b1;
    end else begin
		after_reset <= 1'b0;
		PC <= PC + 4;
		if(~|stage_cnt) begin
			instruction_latch = SINGLE_BUS == "TRUE" ? data_i : pgm_inst_i;
			if(~skip_execution && int_request && int_en_o) begin
				if(VECTOR_INT_TABLE_SIZE != 0) begin
					PC <= RESET_VECTOR + 4;
					RIP <= PC_FOR_AUIPC_AND_REL_JMP;
					put_int_table_addr <= 1'b1;
					int_ack_o <= 2 ** (current_int_vect_request - 1);
					reg_mcause <= current_int_vect_request - 1;
					reg_mstatus[`REG_MSTATUS_MIE_bp] <= 1'b0;
					stage_cnt <= 2'd1;
					skip_execution <= 1'b1;
					enter_interrupt = 1'b1;
				end
			end
		end
        if(~|data_addr_o[ADDR_BUS_WIDTH - 1:8] && data_wr_w_o)
        begin
            case(data_addr_o[7:0])
            	`REG_RIP: RIP <= rs2;
            	`REG_MSTATUS: reg_mstatus <= rs2;
            endcase
        end
		casex({enter_interrupt, skip_execution, stage_cnt, instruction_latch})
			{1'b0, 1'b0, 2'bx0, `RISC_V_ALU_INST_MRET}: begin
				if(VECTOR_INT_TABLE_SIZE != 0) begin
					PC <= RIP;
					skip_execution <= 1'b1;
					reg_mstatus[`REG_MSTATUS_MIE_bp] <= 1'b1;
				end
			end
			{1'b0, 1'b0, 2'd0, `RISC_V_ALU_INST_EXT_I_STORE}: begin
				if(SINGLE_BUS == "TRUE") begin
					PC <= PC;
					stage_cnt <= 2'd1;
				end
			end
			{1'b0, 1'b0, 2'd1, `RISC_V_ALU_INST_EXT_I_STORE}: begin
				if(SINGLE_BUS == "TRUE") begin
					PC <= PC;
					stage_cnt <= 2'd2;
					instruction_latch = data_i;
				end
			end
			{1'b0, 1'b0, 2'd0, `RISC_V_ALU_INST_EXT_I_LOAD}: begin
				PC <= PC;
				stage_cnt <= 2'd1;
			end
			{1'b0, 1'b0, 2'd1, `RISC_V_ALU_INST_EXT_I_LOAD}: begin
				if(SINGLE_BUS == "TRUE") begin
					PC <= PC;
					stage_cnt <= 2'd2;
				end
			end
			{1'b0, 1'b0, 2'bx0, `RISC_V_ALU_INST_JAL}: begin
				PC <= (/*PC == RESET_VECTOR*/after_reset ? pc_delayed_1 : PC_FOR_AUIPC_AND_REL_JMP) + {{12{instruction_latch[31]}}, instruction_latch[19:12], instruction_latch[20], instruction_latch[30:21], 1'b0};
				skip_execution <= 1'b1;
			end
			{1'b0, 1'b0, 2'bx0, `RISC_V_ALU_INST_JALR}: begin
				PC <= PC;
				stage_cnt <= 2'd1;
			end
			{1'b0, 1'b0, 2'bx1, `RISC_V_ALU_INST_JALR}: begin
				skip_execution <= 1'b1;
				PC <= {{21{instruction_latch[31]}}, instruction_latch[30:20]} + {rs1[31:1], 1'b0};
			end
			{1'b0, 1'b0, 2'bx0, `RISC_V_ALU_INST_BEQ_BNE},
			{1'b0, 1'b0, 2'bx0, `RISC_V_ALU_INST_BLT_BGE},
			{1'b0, 1'b0, 2'bx0, `RISC_V_ALU_INST_BLTU_BGEU}: begin
				PC <= PC;
				stage_cnt <= 2'd1;
			end
			{1'b0, 1'b0, 2'bx1, `RISC_V_ALU_INST_BEQ_BNE}: begin
				if(rs1_eq_rs2 ^ instruction_latch[12]) begin
					PC <= PC_FOR_AUIPC_AND_REL_JMP + {{21{instruction_latch[31]}}, instruction_latch[7], instruction_latch[30:25], instruction_latch[11:8], 1'b0};
					skip_execution <= 1'b1;
				end
			end
			{1'b0, 1'b0, 2'bx1, `RISC_V_ALU_INST_BLT_BGE}: begin
				if(rs1_lt_rs2 ^ instruction_latch[12]) begin
					PC <= PC_FOR_AUIPC_AND_REL_JMP + {{21{instruction_latch[31]}}, instruction_latch[7], instruction_latch[30:25], instruction_latch[11:8], 1'b0};
					skip_execution <= 1'b1;
				end
			end
			{1'b0, 1'b0, 2'bx1, `RISC_V_ALU_INST_BLTU_BGEU}: begin
				if(rs1_ltu_rs2 ^ instruction_latch[12]) begin
					PC <= PC_FOR_AUIPC_AND_REL_JMP + {{21{instruction_latch[31]}}, instruction_latch[7], instruction_latch[30:25], instruction_latch[11:8], 1'b0};
					skip_execution <= 1'b1;
				end
			end
        endcase
    end
end

regs # (
	.PLATFORM(PLATFORM)
)regs_inst(
	.clk(clk_i),
	.rs1a(rs1a),
	.rs1(rs1),
	.rs1r(1'b1),
	.rs2a(rs2a),
	.rs2(rs2),
	.rs2r(1'b1),
	.rda(rda),
	.rd(rd),
	.rdw(rdw)
);

risc_v_alu_lite # (
	.PLATFORM("XILINX"),
	.EXTENSION_M(EXTENSION_M),
	.EXTENSION_MDIV(EXTENSION_MDIV)
)risc_v_alu_lite_inst(
	.clk(clk_i),
	.instruction(instruction_latch),
	.rs1(rs1),
	.rs2(rs2),
	.rd(rd_alu),
	.rs1_eq_rs2(rs1_eq_rs2),
	.rs1_lt_rs2(rs1_lt_rs2),
	.rs1_ltu_rs2(rs1_ltu_rs2),
	.arith_inst_decode_fault() 
);

endmodule
