.section .text
.global _start

_start:
    li sp, 1020
    jal my_main

loop:
    j loop

