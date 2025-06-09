#!/usr/bin/env bash

set -euo pipefail

# Configuration
VM_NAME="nixvm"
VM_DISK_PATH="./.vm-tmp/${VM_NAME}.qcow2"
VM_ISO_PATH="./.vm-tmp/nixos-minimal-24.05.20240319.0f0c0c0-x86_64-linux.iso"

# Stop QEMU if running
if [ -S ./qemu-monitor.sock ]; then
    echo "Stopping QEMU..."
    echo "quit" | socat - UNIX-CONNECT:./qemu-monitor.sock
    rm -f ./qemu-monitor.sock
fi

# Remove VM files
echo "Cleaning up VM files..."
[ -f "$VM_DISK_PATH" ] && rm -f "$VM_DISK_PATH"
[ -f "$VM_ISO_PATH" ] && rm -f "$VM_ISO_PATH"
[ -f "./qemu-serial.log" ] && rm -f "./qemu-serial.log"

echo "Cleanup complete." 