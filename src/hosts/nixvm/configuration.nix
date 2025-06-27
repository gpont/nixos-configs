{ config, pkgs, ... }:

{
  system.stateVersion = "24.05";

  users.users.gpont = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    password = "password"; # TODO: temp, delete
    shell = pkgs.zsh;
  };

  # sudo without password
  security.sudo.wheelNeedsPassword = false;

  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = true;
  };

  virtualisation.docker.enable = true;

  services.cockpit = {
    enable = true;
    port = 9090;
  };

  environment.systemPackages = with pkgs; [
    git curl wget vim neovim htop btop zsh
  ];

  # Enable flake and new nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enabling garbage collection
  # Automatically delete old generations and unused packages
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.optimise.automatic = true;
}
