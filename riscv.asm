# ----------------------------------------------------------------------
# RISC-V RV32IA Instruction Test Program for 5-Stage Pipeline
# ----------------------------------------------------------------------
# Target: Test various instruction types (R, I, S, B, U, J) and AMO instructions.
# Test Goal: Stress pipeline stages, data hazards, and control hazards.
#
    .global _start
    .option norelax

    .section .text
    _start:
        # 1. Initialization
        # Set up stack pointer (x2) and general registers
        li   x1, 0xAA         # Load Immediate (U-type - technically li is pseudo-instruction,
                            # but it compiles to lui + addi or just addi)
        addi x2, x0, 0x1000   # Set stack pointer (x2) to 4096 (I-type)
        li   x3, 0xBB         # Register for testing
        li   x4, 0xCC         # Register for testing

        # 2. R-Type Instructions (Register-Register Operations)
        # Test ADD (requires forwarding from previous instruction)
        add  x5, x3, x4       # x5 = 0xBB + 0xCC = 0x187. (Potential Data Hazard: x3, x4)
        # Test SUB and XOR (no hazard)
        sub  x6, x4, x3       # x6 = 0xCC - 0xBB = 0x11
        xor  x7, x5, x6       # x7 = 0x187 XOR 0x11

        # 3. I-Type Instructions (Immediate Operations)
        addi x8, x7, 123      # x8 = x7 + 123
        slli x9, x8, 4        # Shift Left Logical Immediate (shift instruction)
        srli x10, x9, 2       # Shift Right Logical Immediate
        andi x11, x10, 0xFF   # Logical AND Immediate
        ori  x12, x11, 0x100   # Logical OR Immediate

        # 4. Data Hazard Test (Load-Use Hazard)
        # Initialize data section for loads/stores
        la   x13, DATA_START  # Load Address (pseudo-instruction: auipc + jalr)
        lw   x14, 0(x13)      # Load Word (I-type)
        addi x15, x14, 10     # Use x14 immediately (requires EX/MEM forwarding)
        sw   x15, 4(x13)      # Store Word (S-type)

        # 5. U-Type Instructions (Upper Immediate)
        lui  x16, 0xCAFE      # x16 = 0xCAFE0000 (Upper 20 bits)
        auipc x17, 0x1         # x17 = PC + (1 << 12) (PC-relative addressing)

        # 6. B-Type Instructions (Branches - Control Hazard Test)
        li   x18, 5
        li   x19, 5
        beq  x18, x19, BRANCH_TAKEN  # Branch if Equal (x18 == x19). Should flush the next instruction.
        li   x20, 0xDEADBEEF        # This instruction should be flushed by the branch

    BRANCH_TAKEN:
        addi x20, x0, 1         # x20 should be 1 if branch is taken correctly

        # 7. J-Type Instruction (Jump)
        jal  x0, JUMP_TARGET    # Jump to JUMP_TARGET, discard return address (x0)
        li   x21, 0xDEADC0DE    # This instruction should be skipped

    JUMP_TARGET:
        addi x21, x20, 2        # x21 = 1 + 2 = 3

        # 8. RV32A Atomic Memory Operation (AMO) Test
        # AMOADD.W: Atomically load *x13, add x21 to it, store the result back,
        # and place the original value into x22.
        # DATA_START initially holds 0x5555AAAA
        amoadd.w x22, x21, (x13) # x22 = 0x5555AAAA (original value)
                                # *(x13) = 0x5555AAAA + 3 (new value)

        # Test complete. Hang in an infinite loop.
        INF_LOOP:
            j INF_LOOP

    .section .data
    .align 4
    DATA_START:
    .word 0x5555AAAA  # Initial value for memory access tests
    .word 0x00000000  # Placeholder for the store instruction