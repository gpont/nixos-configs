{
  description = "NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, ... }:
  let
    # Helper function to create system-specific packages
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    # Helper function to get pkgs for a system
    pkgsFor = system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    # Helper function to create VM configurations
    mkVMConfig = { name, modules ? [] }: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # VMs are always x86_64-linux
      modules = [
        # Base configuration
        ./hosts/${name}/configuration.nix

        # Disk configuration
        disko.nixosModules.disko
        ./hosts/${name}/disko.nix

        # Home manager configuration
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.gpont = import ./home/gpont/home.nix;
        }
      ] ++ modules;
    };
  in {
    nixosConfigurations = {
      # Development VM
      nixvm = mkVMConfig {
        name = "nixvm";
        modules = [
          { networking.hostName = "nixvm"; }
          { time.timeZone = "Europe/Belgrade"; }
        ];
      };
    };

    # Development shells for different systems
    devShells = forAllSystems (system: {
      default = let
        pkgs = pkgsFor system;
        qemuScripts = import ./modules/qemu/default.nix {
          inherit pkgs;
          lib = nixpkgs.lib;
          name = "nixvm";
          memory = 6144;
          cores = 2;
          diskSize = "20G";
          sharedPaths = [ "." ];
        };
      in pkgs.mkShell {
        buildInputs = with pkgs; [
          zsh
          qemu
          curl
          qemuScripts.runNixVMScript
          qemuScripts.runNixVMDiskScript
        ] ++ nixpkgs.lib.optionals (system == "aarch64-darwin") [
          darwin.apple_sdk.frameworks.Security
          darwin.apple_sdk.frameworks.CoreServices
        ];
        shell = "${pkgs.zsh}/bin/zsh -l";
      };
    });

    # Formatter for nix files
    formatter = forAllSystems (system: pkgsFor system).nixfmt;
  };
}
