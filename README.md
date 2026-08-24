# E85 HMC Final Project

This repository contains a Spring 2026 class project for **E85: Digital Electronics and Computer Engineering** at Harvey Mudd College. The project implements a multicycle RISC-V processor in SystemVerilog.

The processor uses a finite-state controller and a multicycle datapath with unified instruction and data memory. It supports the instruction types exercised in the course project: `lw`, `sw`, R-type ALU operations, `beq`, I-type ALU operations, and `jal`.

## Structure

- `rtl/top.sv` - top-level processor and memory integration
- `rtl/riscv_multi.sv` - processor-level controller/datapath wiring
- `rtl/controller.sv` - control unit, state machine, and instruction decoders
- `rtl/datapath.sv` - multicycle datapath
- `rtl/memory.sv` - unified word-addressed memory
- `rtl/components.sv` - register file, ALU, immediate extender, muxes, and registers
- `sim/riscv_testbench.sv` - course testbench that checks the final memory write
- `program/memfile.asm` - annotated RISC-V test program
- `program/memfile.dat` - machine-code memory image loaded by the processor
- `filelist.f` - simulation source list

## Simulation

The supplied test program exercises `add`, `sub`, `and`, `or`, `slt`, `addi`, `lw`, `sw`, `beq`, and `jal`. A successful simulation writes decimal `71` to byte address `84`.

Run the simulator from the repository root so the memory image path resolves correctly. For example, with Icarus Verilog:

```bash
iverilog -g2012 -s testbench -o processor.vvp -c filelist.f
vvp processor.vvp
```

This is an educational processor implementation, not a complete or production-ready RISC-V core.

## Author

Nathan Nguyen
