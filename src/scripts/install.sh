#!/usr/bin/env bash
set -euo pipefail

# === Settings ===
REPO_DIR="/repo"
HOSTNAME="nixvm"
DISK="/dev/vda"  # Change to your target disk if needed

# === Installation steps overview ===
echo -e "\n🚀 NixOS Automated Install Script\n"

# === 1. Mount repository ===
echo "1️⃣  Mounting repository..."
if ! mountpoint -q "$REPO_DIR"; then
  mkdir -p "$REPO_DIR"
  if ! mount -t 9p -o trans=virtio,version=9p2000.L hostrepo "$REPO_DIR"; then
    echo "❌ Failed to mount repository!"
    exit 1
  fi
fi
echo "✅ Repository mounted at $REPO_DIR"

# === 2. Check for root privileges ===
echo "2️⃣  Checking for root privileges..."
if [[ $EUID -ne 0 ]]; then
  echo "❌ This script must be run as root (or with sudo)!"
  exit 1
fi

echo "✅ Root privileges confirmed."

# === 3. Setup network and DNS ===
echo "3️⃣  Setting up network and DNS..."
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

if ! ping -c1 8.8.8.8 &>/dev/null; then
  echo "❌ No internet connection!"
  exit 1
fi

if ! ping -c1 1.1.1.1 &>/dev/null; then
  echo "❌ Backup DNS not reachable!"
  exit 1
fi

echo "✅ Network and DNS configured."

# === 4. Check if disk is already partitioned ===
echo "4️⃣  Checking if $DISK is already partitioned..."
if lsblk -n -o MOUNTPOINT $DISK* | grep -q "/"; then
  echo "✅ $DISK already has a root filesystem. Skipping disko."
else
  echo "🛠  $DISK is not partitioned or mounted. Running disko..."
  export NIX_BUILD_SHELL=/bin/sh
  mkdir -p /tmp/nix-tmp
  export TMPDIR=/tmp/nix-tmp
  export NIX_CONFIG="experimental-features = nix-command flakes"
  nix run github:nix-community/disko -- --mode disko --flake "$REPO_DIR#${HOSTNAME}"
  echo "✅ Disk partitioned and filesystems created."
fi

# === 5. Mount filesystems ===
echo "5️⃣  Mounting filesystems..."
if mount | grep "/mnt"; then
  echo "✅ Filesystems mounted."
else
  echo "❌ Disko did not mount /mnt, please check your config!"
  exit 1
fi

# === 7. Install NixOS using flakes ===
echo "6️⃣  Installing NixOS..."
nixos-install --flake "${REPO_DIR}#${HOSTNAME}" --no-root-passwd

echo -e "\n🎉 Installation complete! Please reboot your system.\n"
