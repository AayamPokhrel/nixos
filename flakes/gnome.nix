{ config, pkgs, ... }:

{
  # GNOME Management & Customization
  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.system-monitor
    gnome-software
    gnome-extension-manager
    gnome-tweaks
    refine
    libgtop
    btop
  ];

  # Color Management Daemon (required for accurate HDR tone mapping and ICC profiles)
  services.colord.enable = true;

  # Native browser connector for extensions.gnome.org
  services.gnome.gnome-browser-connector.enable = true;

  # Flatpak
  services.flatpak.enable = true;

  # Dconf
  programs.dconf.enable = true;
}
