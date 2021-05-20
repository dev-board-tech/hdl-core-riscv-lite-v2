onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sim/ardyFPGA_inst/rst_i
add wave -noupdate /sim/ardyFPGA_inst/clk_i
add wave -noupdate -radix hexadecimal /sim/ardyFPGA_inst/led
add wave -noupdate -radix hexadecimal /sim/ardyFPGA_inst/pgm_addr
add wave -noupdate -radix hexadecimal /sim/ardyFPGA_inst/pgm_data
add wave -noupdate -radix hexadecimal /sim/ardyFPGA_inst/data_addr
add wave -noupdate -radix hexadecimal /sim/ardyFPGA_inst/data_out
add wave -noupdate /sim/ardyFPGA_inst/data_wr_w
add wave -noupdate /sim/ardyFPGA_inst/data_wr_h
add wave -noupdate /sim/ardyFPGA_inst/data_wr_b
add wave -noupdate -radix hexadecimal /sim/ardyFPGA_inst/data_in
add wave -noupdate /sim/ardyFPGA_inst/data_rd_w
add wave -noupdate /sim/ardyFPGA_inst/data_rd_h
add wave -noupdate /sim/ardyFPGA_inst/data_rd_b
add wave -noupdate /sim/ardyFPGA_inst/data_en
add wave -noupdate /sim/ardyFPGA_inst/pgm_en
add wave -noupdate /sim/ardyFPGA_inst/io_en
add wave -noupdate /sim/ardyFPGA_inst/core_stall
add wave -noupdate -radix hexadecimal /sim/ardyFPGA_inst/rom_bus_out
add wave -noupdate -radix hexadecimal /sim/ardyFPGA_inst/ram_bus_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {65531180 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 217
configure wave -valuecolwidth 180
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {64665305 ps} {68288679 ps}
