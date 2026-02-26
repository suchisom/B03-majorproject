
# 32-Bit Pipelined RISC-V Processor

<img width="829" height="1006" alt="image" src="https://github.com/user-attachments/assets/79bfe00f-106f-491f-8bbe-c495a7a87bc5" />


## Overview

This repository contains the RTL implementation and verification environment for a custom 32-bit RISC-V CPU. The processor implements a standard 5-stage pipeline based on the RV32I instruction set architecture. It is built entirely in Verilog and features a robust hazard detection and forwarding unit to handle data dependencies and control flow changes seamlessly.

The project also includes a complete bare-metal software toolchain, allowing standard C code to be compiled, linked, and executed directly on the simulated hardware.

## Architecture & Features

The core is divided into the classic 5-stage pipeline: Fetch, Decode, Execute, Memory, and Writeback.

* **Hazard Unit:** Fully implements data hazard forwarding (MEM-to-EX and WB-to-EX paths) to minimize pipeline stalls. It includes stall generation for Load-Use hazards and pipeline flushing for branch mispredictions.
* **Register File with Internal Forwarding:** Implements a "write-first" architecture. If a register is read in the same clock cycle it is being written, the new data is forwarded immediately, inherently resolving distance-2 Writeback-to-Execute hazards.
* **ALU & Control:** Supports standard RV32I arithmetic, logical, shift, and branching operations. Signed and unsigned comparisons are correctly isolated to ensure accurate control flow execution.
* **Memory Architecture:** Separate Instruction Memory and Data Memory modules to prevent structural hazards during simultaneous instruction fetch and memory access operations.

## Software Toolchain

To bridge the gap between high-level algorithms and the hardware, the project uses a custom GCC compilation pipeline:

* **`crt0.s` (C Run-Time Zero):** Bootstraps the CPU by initializing the stack pointer and safely catching the processor in an infinite loop upon program termination.
* **`linker.ld`:** Maps the compiled text, data, and bss sections to the precise physical memory addresses expected by the Verilog memory modules.
* **Compilation Flow:** Utilizes `riscv64-unknown-elf-gcc` to generate the ELF binary, followed by `objcopy` and a custom Python script (`make_hex.py`) to generate the hex machine-code files required by the Verilog `$readmemh` function.

## Verification & Stress Testing

The CPU has been successfully verified using complex C programs that stress-test pipeline forwarding, memory access, and branch recovery. Test suites include:

* **Array Manipulation:** Algorithms like Bubble Sort to test heavy nested looping, pointer math, and continuous memory swapping (Load-to-Use hazards).
* **Algorithmic Edge Cases:** Implementations checking for max consecutive sequences and array palindromes using two-pointer approaches. These heavily test the internal forwarding logic, branch prediction recovery, and simultaneous memory pointer increments/decrements.
* **Data Dependencies:** Tight arithmetic loops, such as generating the Fibonacci sequence, to verify zero-cycle ALU forwarding without stalling.

## Automation GUI

Included in the repository is a Python-based graphical user interface (`cpu_runner_gui.py`) built with `tkinter`. This tool automates the entire testing process:

1. Selects the target C source file.
2. Compiles the runtime environment and linker script.
3. Generates the ELF, Binary, and Hex files.
4. Compiles the Verilog source code using `iverilog`.
5. Executes the simulation using `vvp` and streams the console output directly into the application window.

## How to Run

### Prerequisites

* Icarus Verilog (`iverilog` and `vvp`)
* RISC-V GNU Compiler Toolchain (`riscv64-unknown-elf-gcc`)
* Python 3 (for automation scripts)

### Execution via GUI

1. Run the Python GUI tool:
```bash
python3 cpu_runner_gui.py

```


2. Click **Select C File** and choose your desired test file (e.g., `test_add.c` or `stress_test.c`).
3. Click **Compile & Run Simulation**.
4. The output trace, including final memory writes (e.g., `Wrote 1 to 0x100`), will appear in the integrated console.

### Execution via Terminal

If running manually, execute the following build sequence:

```bash
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -c crt0.s -o crt0.o
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -O1 -mno-save-restore -ffreestanding -nostdlib -T linker.ld crt0.o your_c_file.c -o program.elf
riscv64-unknown-elf-objcopy -O binary program.elf program.bin
python3 make_hex.py program.bin memfile.hex
iverilog -o riscv_core -s pipeline_tb *.v
vvp riscv_core

```

---
