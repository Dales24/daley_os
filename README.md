# daley_os

A **from-scratch operating system**, designed to be **security-first** and a
**good home for AI workloads**.

> **Honest scope:** a secure, AI-optimized OS is a multi-year project. This repo
> is the **kernel foundation** — a real Multiboot kernel that boots in QEMU and
> prints to the screen — plus a clear design + roadmap for the two goals. Nothing
> here claims to be a finished secure/AI OS; it's the ground floor, built right.

## What works today

- A **Multiboot kernel** that GRUB (or `qemu -kernel`) loads at 1 MiB.
- A small **VGA text terminal** — the kernel boots and prints a banner:

```
daley_os
a from-scratch, security-first OS for AI workloads

[ok] multiboot kernel loaded at 1 MiB
[ok] VGA text terminal online
[..] next: GDT, IDT, paging, physical memory manager
```

## Layout

```
daley_os/
├─ src/
│  ├─ boot.asm      Multiboot header + entry point (NASM)
│  ├─ kernel.c      kernel_main + VGA text terminal (freestanding C)
│  └─ linker.ld     links the kernel at 1 MiB, Multiboot header first
├─ grub.cfg         GRUB menu entry (for the .iso)
├─ Makefile         build / run / iso
├─ run.sh           build + boot in QEMU
└─ docs/ARCHITECTURE.md   the security-first + AI design and roadmap
```

## Build & run

You need a **freestanding i686 toolchain**, NASM, and QEMU. The reliable path is
an `i686-elf` cross-compiler:

```bash
# Debian/Ubuntu deps for building the cross-compiler + running:
sudo apt install -y nasm qemu-system-x86 xorriso grub-pc-bin build-essential
# ...then build an i686-elf gcc/binutils (see https://wiki.osdev.org/GCC_Cross-Compiler)

make run        # build build/kernel.bin and boot it in QEMU
make iso        # build a GRUB-bootable daley_os.iso
```

(A host `gcc -m32` can substitute on Linux with multilib installed — set
`CC="gcc -m32"` — but a cross-compiler avoids host-libc surprises.)

## The vision (see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md))

- **Security-first:** a minimal, auditable kernel; **capability-based** access
  (no ambient root); W^X + SMEP/SMAP/KASLR; memory-safe (Rust) services over a
  tiny core; secure boot + sandboxed workloads.
- **Good for AI:** a huge-page **tensor allocator** for model weights/KV-caches,
  an **inference-aware scheduler** (throughput + bounded latency), accelerators
  as capability-guarded first-class resources, and a narrow, safe "run a
  sandboxed model" ABI.

## Roadmap (next up)

**Phase 1 — CPU & memory:** GDT + IDT + interrupt handlers → PIT timer +
keyboard → physical memory manager (from the Multiboot map) → paging + kernel
heap + NX/W^X. Only once these are real do the security and AI layers become
buildable — see the architecture doc for the full plan.
