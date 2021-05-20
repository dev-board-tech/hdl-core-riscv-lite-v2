if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2.2} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "C:/GitHubDevBoard/hdl-core-riscv-lite-v2/example/lattice"
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- hdl_core_riscv_lite_v2_impl_1_cpe.ldc
run_engine_newmsg cpe -f "hdl_core_riscv_lite_v2_impl_1.cprj" "PLL_DEV_48M.cprj" -a "iCE40UP" -o hdl_core_riscv_lite_v2_impl_1_cpe.ldc
# synthesize top design
file delete -force -- hdl_core_riscv_lite_v2_impl_1.vm hdl_core_riscv_lite_v2_impl_1.ldc
run_engine_newmsg synthesis -f "hdl_core_riscv_lite_v2_impl_1_lattice.synproj"
run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o hdl_core_riscv_lite_v2_impl_1_syn.udb hdl_core_riscv_lite_v2_impl_1.vm] "C:/GitHubDevBoard/hdl-core-riscv-lite-v2/example/lattice/impl_1/hdl_core_riscv_lite_v2_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
