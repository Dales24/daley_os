#!/usr/bin/env bash
# Build and boot daley_os in QEMU.
set -euo pipefail
cd "$(dirname "$0")"

make
exec "${QEMU:-qemu-system-i386}" -kernel build/kernel.bin
