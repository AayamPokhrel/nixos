{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ] ++ (
      map (fn: ./flakes + "/${fn}")
        (builtins.filter (fn: lib.hasSuffix ".nix" fn)
          (builtins.attrNames (builtins.readDir ./flakes)))
    );

  # Boot loader & Kernel (uses default stable kernel with prebuilt NVIDIA drivers)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Localization & Time Zone
  time.timeZone = "Asia/Kathmandu";
  i18n.defaultLocale = "en_US.UTF-8";

  # Display Manager & GNOME Desktop
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing
  services.printing.enable = true;

  # Sound with PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User Account (includes 'video' and 'input' for hardware access)
  users.users."legion" = {
    isNormalUser = true;
    description = "aayam";
    extraGroups = [ "networkmanager" "wheel" "video" "input" ];
  };

  # Default browser
  programs.firefox.enable = true;

  # GPG Agent
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Preserve SSH agent across sudo for git operations in nixos-rebuild
  security.sudo.extraConfig = ''
    Defaults env_keep += "SSH_AUTH_SOCK"
  '';

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Flake settings & auto-update on rebuild (tarball-ttl = 0 ensures remote git flakes refresh)
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    tarball-ttl = 0;
  };

  # Minimal required base system packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    gnupg
    pinentry-tty
  ];

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ] ++ (builtins.filter pkgs.lib.isDerivation (builtins.attrValues pkgs.nerd-fonts));

  system.stateVersion = "26.05";
}
