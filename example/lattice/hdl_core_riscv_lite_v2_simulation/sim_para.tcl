lappend auto_path "C:/lscc/radiant/2.2/scripts/tcl/simulation"
package require simulation_generation
set ::bali::simulation::Para(DEVICEPM) {ice40tp}
set ::bali::simulation::Para(DEVICEFAMILYNAME) {iCE40UP}
set ::bali::simulation::Para(PROJECT) {hdl_core_riscv_lite_v2}
set ::bali::simulation::Para(PROJECTPATH) {D:/GitHubDevBoard/hdl-core-common/core/riscv/hdl-core-riscv-lite-v2/prj/lattice}
set ::bali::simulation::Para(FILELIST) {"D:/GitHubDevBoard/hdl-core-common/core/riscv/hdl-core-riscv-lite-v2/prj/lattice/source/impl_1/top.v" "D:/GitHubDevBoard/hdl-core-common/core/riscv/hdl-core-riscv-lite-v2/prj/lattice/PLL_DEV_48M/rtl/PLL_DEV_48M.v" "D:/GitHubDevBoard/hdl-core-common/core/riscv/hdl-core-riscv-lite-v2/prj/lattice/source/impl_1/arduFPGA.v" "D:/GitHubDevBoard/hdl-core-common/core/riscv/hdl-core-riscv-lite-v2/io_bus_dmux.v" "D:/GitHubDevBoard/hdl-core-common/core/riscv/hdl-core-riscv-lite-v2/memory.v" "D:/GitHubDevBoard/hdl-core-common/core/riscv/hdl-core-riscv-lite-v2/reg.v" "D:/GitHubDevBoard/hdl-core-common/core/riscv/hdl-core-riscv-lite-v2/risc-v-alu-l.v" "D:/GitHubDevBoard/hdl-core-common/core/riscv/hdl-core-riscv-lite-v2/risc-v-l-h.v" "D:/GitHubDevBoard/hdl-core-common/core/riscv/hdl-core-riscv-lite-v2/risc-v-v2.v" "D:/GitHubDevBoard/hdl-core-common/core/riscv/hdl-core-riscv-lite-v2/prj/lattice/source/impl_1/sim.v" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none" "none" "none" "none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"work" "work" "work" "work" "work" "work" "work" "work" "work" "work" }
set ::bali::simulation::Para(COMPLIST) {"VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_ice40up}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {sim}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {}
set ::bali::simulation::Para(LANGUAGE) {VERILOG}
set ::bali::simulation::Para(SDFPATH)  {}
set ::bali::simulation::Para(INSTALLATIONPATH) {C:/lscc/radiant/2.2}
set ::bali::simulation::Para(MEMPATH) {D:/GitHubDevBoard/hdl-core-common/core/riscv/hdl-core-riscv-lite-v2/prj/lattice/PLL_DEV_48M}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(ISRTL)  {1}
set ::bali::simulation::Para(HDLPARAMETERS) {}
::bali::simulation::ModelSim_Run
