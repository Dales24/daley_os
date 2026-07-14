; Multiboot1 header + entry point. GRUB (or `qemu -kernel`) loads this, then we
; set up a stack and hand control to kernel_main (in kernel.c).
; Assemble with:  nasm -f elf32 boot.asm -o boot.o

MBALIGN  equ 1 << 0                ; align loaded modules on page boundaries
MEMINFO  equ 1 << 1                ; provide a memory map
FLAGS    equ MBALIGN | MEMINFO
MAGIC    equ 0x1BADB002            ; the Multiboot1 magic number
CHECKSUM equ -(MAGIC + FLAGS)      ; header must sum to zero

section .multiboot
align 4
    dd MAGIC
    dd FLAGS
    dd CHECKSUM

; A small stack (16 KiB). The System V ABI wants a 16-byte-aligned stack.
section .bss
align 16
stack_bottom:
    resb 16384
stack_top:

section .text
global _start
_start:
    mov esp, stack_top            ; set up the stack
    extern kernel_main
    call kernel_main              ; into C

    cli                          ; if the kernel returns, halt forever
.hang:
    hlt
    jmp .hang
