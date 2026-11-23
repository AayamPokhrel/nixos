{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # System inspection & performance
    ripgrep
    nvme-cli
    vulkan-tools
    libdrm
    pciutils
    clinfo

    # File and archive utilities
    tree
    zip
    unzip
    which
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
}
