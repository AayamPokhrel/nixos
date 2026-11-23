{ config, pkgs, ... }:

{
  # NVIDIA DRM modesetting parameter
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
  ];

  # Hardware Acceleration & Vulkan (64-bit and 32-bit)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
    ];
  };

  # NVIDIA Driver Stack
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    # Uses open-source kernel modules (recommended for Turing, Ada Lovelace, and Blackwell architectures)
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
