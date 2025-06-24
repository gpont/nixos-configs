#!/usr/bin/env bash

set -euo pipefail

# Configuration
VM_NAME="nixvm"
VM_MEMORY="6144"  # 6GB for live system
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

# Make install script executable
chmod +x ./src/scripts/install.sh

# Start QEMU
# -boot order=d \ - from CD
# -boot order=c \ - from disk
echo "Starting QEMU VM..."
qemu-system-x86_64 \
    -m "$VM_MEMORY" \
    -smp "$VM_CORES" \
    -drive file="$VM_DISK_PATH",if=virtio,format=qcow2 \
    -cdrom "$VM_ISO_PATH" \
    -net nic,model=virtio \
    -net user \
    -boot order=d \
    -nographic \
    -serial mon:stdio \
    -monitor unix:./qemu-monitor.sock,server,nowait \
    -fsdev local,id=repo,path=src,security_model=none \
    -device virtio-9p-pci,fsdev=repo,mount_tag=hostrepo