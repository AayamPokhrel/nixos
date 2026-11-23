{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    google-chrome
    telegram-desktop
    libreoffice
    vscode
    neovim
    fastfetch
    tmux
    jamesdsp
  ];

  # Zsh shell
  programs.zsh.enable = true;
}
