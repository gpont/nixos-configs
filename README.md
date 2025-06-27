# NixOS Server Configs

This repository contains NixOS configurations for servers using flakes, home-manager, and automatic disk partitioning with [disko](https://github.com/nix-community/disko).

## Prerequisites

### Installing Nix on macOS

1. Install Nix package manager:

```bash
# For macOS Catalina and newer:
sh <(curl -L https://nixos.org/nix/install)

# After installation, source the nix profile:
. ~/.nix-profile/etc/profile.d/nix.sh
```

2. Enable Flakes and Nix Command:

```bash
# Create or edit ~/.config/nix/nix.conf
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

3. Install Git (if not already installed):

```bash
nix-env -iA nixpkgs.git
```

## Quick Start

1. Clone the repository:

```bash
git clone https://github.com/gpont/nixos-config.git
cd nixos-config/src
```

2. Enter the development shell (this will provide all necessary tools):

```bash
nix develop
```

3. Start the VM:

```bash
run-nixvm
```

This will automatically:

- Create a VM directory at `.vm-tmp`
- Download the NixOS ISO if needed
- Create a virtual disk if needed
- Start QEMU with the correct configuration

4. After entering the live-mode of the NixOS ISO, you need to manually mount the repository:

```sh
sudo su
mkdir -p /repo
mount -t 9p -o trans=virtio,version=9p2000.L,msize=104857600 src /repo
```

5. After mounting, you can run install script to automatically install and configure the system:

```sh
cd /repo
./scripts/install.sh
```

6. After installation completes, reboot the VM:

```bash
reboot
```

7. After rebooting power off machine and run vm from disk:

```bash
sudo poweroff
```

```bash
run-nixvm-disk
```

## Project Structure

```
src/
├── flake.nix              # Main entry point, defines VM configurations
├── modules/               # Custom NixOS modules
│   ├── vm/               # VM-specific configuration (network, 9p, etc.)
│   └── qemu/             # QEMU management module
├── hosts/                # Host-specific configurations
│   └── nixvm/           # Configuration for the development VM
│       ├── configuration.nix
│       └── disko.nix    # Disk partitioning configuration
├── home/                 # Home-manager configurations
│   └── gpont/
│       └── home.nix     # User-specific configuration
└── scripts/
    └── install.sh       # VM installation script
```

## Configuration

### Modifying VM Settings

Edit `src/hosts/nixvm/configuration.nix` to change VM parameters:

```nix
{
  vm = {
    enable = true;
    memory = 6144;  # Memory in MB
    cores = 2;      # CPU cores
    diskSize = "20G";
    sharedPaths = [ "../../src" ];  # Paths to share via 9p
  };
}
```

### Adding Software

Add system packages in `configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  git vim curl wget
];
```

Add user packages in `home/gpont/home.nix`:

```nix
home.packages = with pkgs; [
  firefox vscode
];
```

## Development Workflow

1. Make changes to the configuration files
2. Start/restart the VM with `run-nixvm`
3. Inside the VM, test your changes:

```bash
sudo nixos-rebuild switch --flake /repo#nixvm
```

## Cleanup

To remove all VM-related files:

```bash
rm -rf .vm-tmp
```

## License

This project is licensed under the [MIT License](LICENSE).

## Labels

- NixOS
- Flakes
- Home-Manager
- Disko
- Server Configuration
- QEMU
- Virtual Machine
