# Build the daley_os kernel.
#
# Recommended toolchain: an i686-elf cross-compiler + nasm + qemu.
#   (a host `gcc -m32` can work on Linux with multilib, but a cross-compiler is
#    the reliable path — see README.)
#
#   make            # build build/kernel.bin
#   make run        # boot it in QEMU
#   make iso        # build a GRUB-bootable daley_os.iso
#   make clean

CC      ?= i686-elf-gcc
AS      ?= nasm
QEMU    ?= qemu-system-i386

CFLAGS  := -std=gnu11 -ffreestanding -O2 -Wall -Wextra
LDFLAGS := -ffreestanding -O2 -nostdlib

BUILD   := build
KERNEL  := $(BUILD)/kernel.bin
ISO     := daley_os.iso

$(KERNEL): $(BUILD)/boot.o $(BUILD)/kernel.o src/linker.ld
	$(CC) -T src/linker.ld $(LDFLAGS) -o $@ $(BUILD)/boot.o $(BUILD)/kernel.o -lgcc

$(BUILD)/boot.o: src/boot.asm | $(BUILD)
	$(AS) -f elf32 $< -o $@

$(BUILD)/kernel.o: src/kernel.c | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD):
	mkdir -p $(BUILD)

run: $(KERNEL)
	$(QEMU) -kernel $(KERNEL)

iso: $(KERNEL)
	mkdir -p $(BUILD)/isodir/boot/grub
	cp $(KERNEL) $(BUILD)/isodir/boot/kernel.bin
	cp grub.cfg $(BUILD)/isodir/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO) $(BUILD)/isodir

clean:
	rm -rf $(BUILD) $(ISO)

.PHONY: run iso clean
