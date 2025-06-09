#!/usr/bin/env bash

set -euo pipefail

# Configuration
VM_NAME="nixvm"
VM_MEMORY="4G"
VM_CORES=2
VM_DISK_PATH="./.vm-tmp/${VM_NAME}.qcow2"
VM_ISO_PATH="./.vm-tmp/nixos-minimal-24.05.20240319.0f0c0c0-x86_64-linux.iso"

# Check if disk exists
if [ ! -f "$VM_DISK_PATH" ]; then
    echo "Error: Disk image not found. Run './scripts/setup-vm.sh' first."
    exit 1
fi

# Check if ISO exists
if [ ! -f "$VM_ISO_PATH" ]; then
    echo "Error: NixOS ISO not found. Run './scripts/setup-vm.sh' first."
    exit 1
fi

# Start QEMU
echo "Starting QEMU VM..."
qemu-system-x86_64 \
    -enable-kvm \
    -m "$VM_MEMORY" \
    -smp "$VM_CORES" \
    -drive file="$VM_DISK_PATH",if=virtio,format=qcow2 \
    -drive file="$VM_ISO_PATH",if=virtio,format=raw,readonly=on \
    -net nic,model=virtio \
    -net user \
    -boot d \
    -nographic \
    -monitor unix:./qemu-monitor.sock,server,nowait \
    -serial file:./qemu-serial.log