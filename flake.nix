{
  description = "NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, ... }:
  let
    system = "x86_64-linux";
    localHardware = if builtins.pathExists /etc/nixos/hardware-configuration.nix
      then [ /etc/nixos/hardware-configuration.nix ]
      else [];
  in {
    nixosConfigurations.nixvm = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/nixvm/configuration.nix

        disko.nixosModules.disko
        ./hosts/nixvm/disko.nix

        # Enable home-manager as NixOS-module
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # Apply home configuration for the gpont user
          home-manager.users.gpont = import ./home/gpont/home.nix;
        }
      ] ++ localHardware;
    };
  };
}
