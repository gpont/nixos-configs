{ config, pkgs, ... }:

{
  home.username = "gpont";
  home.homeDirectory = "/home/gpont";

  home.stateVersion = "24.05";

  programs.git = {
    enable = true;
    userName = "Evgenii Guzhikhin";
    userEmail = "gpont97@gmail.com";
  };

  programs.starship.enable = true; # beautify command line
  programs.zoxide.enable = true;   # smart cd
  programs.fzf.enable = true;      # files search
  programs.bat.enable = true;      # cat raplecement

  home.shellAliases = {
    ll = "ls -la";
    gs = "git status";
    cat = "bat";
  };

  home.packages = with pkgs; [
    zsh neovim bat starship fzf zoxide
    unzip ripgrep jq
  ];
}
