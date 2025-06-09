#!/usr/bin/env bash

set -euo pipefail

# Configuration
VM_NAME="nixvm"
VM_MEMORY="4G"
VM_CORES=2
VM_DISK_SIZE="20G"
VM_DISK_PATH="./.vm-tmp/${VM_NAME}.qcow2"
VM_ISO_PATH="./.vm-tmp/nixos-minimal-24.05.20240319.0f0c0c0-x86_64-linux.iso"

# Create disk if it doesn't exist
if [ ! -f "$VM_DISK_PATH" ]; then
    echo "Creating disk image..."
    qemu-img create -f qcow2 "$VM_DISK_PATH" "$VM_DISK_SIZE"
fi

# Download NixOS minimal ISO if it doesn't exist
if [ ! -f "$VM_ISO_PATH" ]; then
    echo "Downloading NixOS minimal ISO..."
    curl -L "https://channels.nixos.org/nixos-24.05/latest-nixos-minimal-x86_64-linux.iso" -o "$VM_ISO_PATH"
fi

echo "VM setup complete. Run './scripts/start-vm.sh' to start the VM." 