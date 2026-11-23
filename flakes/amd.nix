{ config, pkgs, ... }:

{
  # AMD CPU Microcode & Platform Firmware
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # AMD Kernel Parameters:
  # - gpiolib_acpi.ignore_interrupt=AMDI0030:00@4 fixes sleep / wake issue on AMD Legion laptops
  # - amdgpu.dcdebugmask=0x10 exposes modern 3D LUT and color management blocks for Wayland HDR
  boot.kernelParams = [
    "gpiolib_acpi.ignore_interrupt=AMDI0030:00@4"
    "amdgpu.dcdebugmask=0x10"
  ];
}
