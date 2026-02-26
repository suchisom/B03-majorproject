# 32-b-RISCV-CPU-pipelined-5st
finished cpu with c code compatibility 
c to hex code generation using -> riscv gnu toolchain
commands to  convert on linux -> 
   1> riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -Ttext 0x0 -o test_add.elf test_add.c
         -march=rv32i: Tells the compiler to use the base 32-bit integer instruction set (no multiplication/floating point extensions), which matches your CPU design.

         -mabi=ilp32: Uses the 32-bit integer ABI (int, long, and pointers are all 32-bits).

         -nostdlib: Do not include standard C libraries (like printf, malloc, etc.) because your CPU doesn't have an Operating System to support them.

         -Ttext 0x0: Places the code starting strictly at address 0x00000000, which is where your PC resets to.

   2> riscv64-unknown-elf-objcopy -O binary test_add.elf test_add.bin
         The .elf file contains symbols and debug info that the processor can't read. This command strips it down to just the raw machine code.
it reflog

   3>od -An -t x4 -w4 -v test_add.bin > memfile.hex
         -t x4: Output as 4-byte (32-bit) hexadecimal.

         -w4: Output one 4-byte word per line.

         -v: Verbose (don't suppress repeated lines, e.g., if you have many 00000000 instructions).