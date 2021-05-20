# hdl-core-riscv-lite-v2

An optimized RISC-V core mostly for lattice iCE40UP FPGA's

This core is designed to use less resources and not to be a performance core.

This core contain a configurable interrupt controller that support nested interrupts with variable interrupt vector table size.

Is optimized to use BLOCK RAM's as registers.

In dual BUS configuration can execute all instructions in one clock cycle except load from memory and non conditional jumps that need two clock cycles, and conditional branches in three cycles if need to jump, if not will need only two clock cycles.

In single BUS configuration all instructions are executed as in dual BUS configuration except load/store to/from memory that need three clock cycles to execute because data and program load share the same BUS.

The single BUS configuration was developed for the LATTICE iCE40UP FPGA devices to use half memory resources as ROM due to the memory configuration as single port memory in iCE40UP devices, in ROM memory is placed the .data section that is accessed by the CPU as data and need a second port in order to read that data else the same bus need to be shared for program and data.

If someone want a little bit faster core, the core can be configured in double BUS mode and separate the .data section in a separate memory block wired to the data BUS, but this core was developed as a very easy to use core.

The single BUS configuration uses only the data BUS for instruction fetch and data load/store, the dedicated program address BUS is connected to the PC register but the instruction bus is not connected.

Both configurations run at up to 15Mhz on iCE40UP5K with no timing violations and up to 22Mhz overclocked, on Artix A7 -1 ( Digilent Cmod A7-35t ) version run up to 110Mhz with no timing violations.

### FreedomStudio KIND OF "FREEDOM":

Due to the fact that FreedomStudio is no longer represent freedom because they cut the section that allow users to manage native eclipse projects and only allow users to work with SiFive generated cores and they deleted the old releases that allowed management of native eclipse projects, for this reason I saved the newest released version that allowed users to use FreedomStudio for native eclipse projects, this is for very easy project development because and/or beginners and come already configured and include toolchain and tools.

Variables are setup to be decompressed in **"C:\GitHubDevBoard\\"** directory.

The rescued FreedomStudio can be downloaded from here: https://download.devboard.tech/IDE/_FreedomStudio.zip
