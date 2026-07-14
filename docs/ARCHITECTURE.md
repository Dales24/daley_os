# daley_os — architecture & design goals

> **Scope check:** a production, secure, AI-optimized OS is a multi-year effort.
> This document is the **design north star**; the code today is an early kernel
> foundation (it boots and prints). Each goal below is a direction, not a claim
> of completion.

## Two guiding principles

1. **Security-first** — the kernel is the trust anchor; keep it small, keep it
   honest, and give nothing ambient authority.
2. **Good for AI** — treat large-model inference (big contiguous memory,
   accelerators, predictable latency) as a first-class workload, not an
   afterthought bolted onto a general-purpose OS.

## Security design

- **Minimal TCB.** Keep the kernel small and auditable; push drivers and services
  into user space (microkernel-leaning) so a bug in a driver isn't a kernel
  compromise.
- **Memory safety.** Plan to write higher layers (drivers, services) in a
  memory-safe language (Rust) over a tiny C/asm core, shrinking the class of
  memory-corruption bugs that dominate OS CVEs.
- **W^X + hardware defenses.** No page is both writable and executable. Enable
  **SMEP/SMAP** (kernel can't run or blindly read user pages), **NX**, and
  **KASLR** once paging is up.
- **Capability-based access.** No global root, no ambient authority: a process
  can only act on resources it holds an unforgeable capability for. This is the
  biggest departure from Unix and the strongest lever for containing damage.
- **Secure boot + attestation.** Verify the boot chain; be able to attest what
  code is running (relevant for trusting a model host).
- **Sandboxed everything.** Each model / workload runs in its own isolated
  domain with an explicit, least-privilege capability set.

## AI-oriented design

- **Memory built for tensors.** A physical allocator that can hand out large,
  contiguous, huge-page-backed regions for model weights and KV-caches, with NUMA
  awareness — instead of fighting a general-purpose allocator.
- **Predictable scheduling.** An inference-aware scheduler that favors throughput
  and bounded tail latency for serving, distinct from interactive fairness.
- **Accelerator as a first-class citizen.** A driver/ABI model for GPUs/NPUs where
  the device is scheduled and isolated like any other capability-guarded resource.
- **A narrow, safe "run a model" surface.** A small syscall/ABI to load a
  sandboxed model artifact and stream inference, so the attack surface for AI
  workloads is tiny and explicit.

## Roadmap (kernel core first, then the two pillars)

**Phase 0 — boot & I/O** *(where we are)*
- [x] Multiboot kernel, boots at 1 MiB
- [x] VGA text terminal
- [ ] Serial (COM1) logging + terminal scrolling

**Phase 1 — CPU & memory foundations**
- [ ] GDT (segments) + IDT (interrupts) + exception handlers
- [ ] PIC/APIC + PIT timer + keyboard driver
- [ ] Physical memory manager (from the Multiboot memory map)
- [ ] Paging + a kernel heap; enable NX / W^X

**Phase 2 — processes & isolation**
- [ ] User mode, syscalls, a scheduler
- [ ] **Capability model** + per-process address spaces
- [ ] SMEP/SMAP/KASLR; move first drivers to user space

**Phase 3 — the pillars**
- [ ] Security: secure-boot verification, sandbox domains, memory-safe services
- [ ] AI: huge-page tensor allocator, accelerator driver, sandboxed model-run ABI

## Why start this way

Every serious OS starts from a bootable text-printing kernel and grows outward —
you cannot design the secure/AI layers meaningfully until the CPU, interrupts,
and memory management underneath them are real. Phase 1 is the honest next step.
