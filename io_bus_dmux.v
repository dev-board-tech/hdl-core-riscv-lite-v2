/*
 * This IP is the IO demultiplexer for the core data input implementation.
 * 
 * Copyright (C) 2018  Iulian Gheorghiu (morgoth@devboard.tech)
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
 
module io_bus_dmux # (
		parameter NR_OF_BUSSES_IN = 1,
		parameter BITS_PER_BUS = 32,
		parameter USE_OR_METHOD = "TRUE"
		)(
		input [(NR_OF_BUSSES_IN * 32) - 1 : 0]bus_in,
		input [NR_OF_BUSSES_IN - 1 : 0]bus_sel,
		output reg[31:0]bus_out
		);

reg [NR_OF_BUSSES_IN - 1 : 0]tmp_busses_bits;
integer cnt;
generate
if(USE_OR_METHOD == "TRUE") begin
integer cnt_add_busses;
integer cnt_add_bits;
		always @ *
		begin
			for(cnt_add_bits = 0; cnt_add_bits < BITS_PER_BUS; cnt_add_bits = cnt_add_bits + 1)
			begin: DMUX_IO_DATA_BITS
				for(cnt_add_busses = 0; cnt_add_busses < NR_OF_BUSSES_IN; cnt_add_busses = cnt_add_busses + 1)
				begin: DMUX_IO_DATA_BUSES
					tmp_busses_bits[cnt_add_busses] = bus_in[(cnt_add_busses * BITS_PER_BUS) + cnt_add_bits];
				end
				bus_out[cnt_add_bits] = |tmp_busses_bits;
			end
		end
end else begin
always @ *
begin
	bus_out = 32'hz;
	for(cnt = 0; cnt < NR_OF_BUSSES_IN; cnt = cnt + 1)
	begin: DMUX_IO_DATA_BUSES
		if(bus_sel[cnt]) begin
			bus_out = {
				bus_in[(cnt * 32) + 31], bus_in[(cnt * 32) + 30], bus_in[(cnt * 32) + 29], bus_in[(cnt * 32) + 28], 
				bus_in[(cnt * 32) + 27], bus_in[(cnt * 32) + 26], bus_in[(cnt * 32) + 25], bus_in[(cnt * 32) + 24], 
				bus_in[(cnt * 32) + 23], bus_in[(cnt * 32) + 22], bus_in[(cnt * 32) + 21], bus_in[(cnt * 32) + 20], 
				bus_in[(cnt * 32) + 19], bus_in[(cnt * 32) + 18], bus_in[(cnt * 32) + 17], bus_in[(cnt * 32) + 16], 
				bus_in[(cnt * 32) + 15], bus_in[(cnt * 32) + 14], bus_in[(cnt * 32) + 13], bus_in[(cnt * 32) + 12], 
				bus_in[(cnt * 32) + 11], bus_in[(cnt * 32) + 10], bus_in[(cnt * 32) + 9], bus_in[(cnt * 32) + 8], 
				bus_in[(cnt * 32) + 7], bus_in[(cnt * 32) + 6], bus_in[(cnt * 32) + 5], bus_in[(cnt * 32) + 4], 
				bus_in[(cnt * 32) + 3], bus_in[(cnt * 32) + 2], bus_in[(cnt * 32) + 1], bus_in[(cnt * 32) + 0]
			};
		end
	end
end
end
endgenerate
endmodule

