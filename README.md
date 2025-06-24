# NixOS Server Configs

This repository contains my NixOS configurations for servers using flakes, home-manager, and automatic disk partitioning with [disko](https://github.com/nix-community/disko).

## Description

This repository is a collection of NixOS configurations for server environments. It leverages modern Nix tooling such as flakes and home-manager to manage system and user configurations declaratively. The disk partitioning is automated using disko, ensuring a consistent setup across different hosts.

## Quick Start

1. Clone the repository:

   ```sh
   git clone https://github.com/yourusername/nixos-config.git
   cd nixos-config
   ```

2. Review and modify the configurations in `hosts/` and `home/` as needed.
3. Install NixOS using the flake:

   ```sh
   nixos-install --flake .#nixvm
   ```

   Where `nixvm` is the name of your configuration (see flake.nix).

## Testing in QEMU VM

1. Setup the VM:

   ```sh
   ./scripts/setup-vm.sh
   ```

2. Start the VM:

   ```sh
   ./scripts/start-vm.sh
   ```

3. Inside the VM, mount the repository:

   ```sh
   mkdir -p /repo
   mount -t 9p -o trans=virtio,version=9p2000.L repo /repo
   cd /repo
   ```

4. Install NixOS with disko:

   ```sh
   # Format and mount disks using disko
   nix run github:nix-community/disko -- --mode zap_create_mount ./hosts/nixvm/disko.nix

   # Generate hardware configuration
   nixos-generate-config --no-filesystems --root /mnt

   # Install the system
   nixos-install --flake .#nixvm --root /mnt
   ```

5. After installation, reboot and test your configuration:

   ```sh
   reboot
   ```

6. Clean up when done:

   ```sh
   ./scripts/cleanup-vm.sh
   ```

## License

This project is licensed under the [MIT License](LICENSE).

## Labels

- NixOS
- Flakes
- Home-Manager
- Disko
- Server Configuration
