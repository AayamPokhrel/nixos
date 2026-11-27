{ config, lib, pkgs, ... }:

let
  legionFlake = builtins.getFlake "git+https://github.com/AayamPokhrel/LegionSpace4Linux.git";
  legionPkg = legionFlake.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      # Fix hardcoded developer home path in source code
      sed -i 's|/home/aayam422h|/home/legion|g' legion-cli/src/hardware/gpu_modes.rs legion-cli/src/hardware/oled.rs
    '';
    postInstall = (old.postInstall or "") + ''
      # Fix hardcoded path in upstream desktop file so GNOME can find and launch the GUI
      sed -i "s|^Exec=.*|Exec=''${out}/bin/legionspace|" $out/share/applications/legion-space.desktop
    '';
  });
in
{
  imports = [
    legionFlake.nixosModules.default
  ];

  # Lenovo Legion hardware control driver, legionctl, legionspace, legion-cli, udev rules & kernel modules
  hardware.lenovo-legion = {
    enable = true;
    package = legionPkg;
  };

  # Grant non-root desktop users write access to ACPI, fan, battery, GPU, and power limit controls
  systemd.tmpfiles.rules = [
    # ACPI Platform Profile (Quiet, Balanced, Performance, Custom)
    "z /sys/firmware/acpi/platform_profile 0666 root root -"
    "z /sys/firmware/acpi/platform_profile_choices 0666 root root -"

    # Lenovo Ideapad VPC2004 Platform Device (Conservation Mode, Fn Lock, USB Charging, Camera Power)
    "z /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode 0666 root root -"
    "z /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/fan_mode 0666 root root -"
    "z /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/fn_lock 0666 root root -"
    "z /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/usb_charging 0666 root root -"
    "z /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/camera_power 0666 root root -"

    # Cooling Fans (hwmon fan targets)
    "z /sys/devices/platform/DC2A8805-3A8C-41BA-A6F7-092E0089CD3B-6/hwmon/hwmon*/fan1_target 0666 root root -"
    "z /sys/devices/platform/DC2A8805-3A8C-41BA-A6F7-092E0089CD3B-6/hwmon/hwmon*/fan2_target 0666 root root -"
    "z /sys/class/hwmon/hwmon*/fan1_target 0666 root root -"
    "z /sys/class/hwmon/hwmon*/fan2_target 0666 root root -"

    # Lenovo WMI Custom Mode Firmware Attributes (PL1, PL2, PL3, CPU/GPU thermal limits)
    "z /sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/*/current_value 0666 root root -"
    "z /sys/devices/virtual/firmware-attributes/lenovo-wmi-other-0/attributes/*/current_value 0666 root root -"

    # NVIDIA dGPU PCI runtime power management and d3cold control (for GPU mode switching)
    "z /sys/bus/pci/devices/0000:01:00.0/power/control 0666 root root -"
    "z /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed 0666 root root -"
  ];

  # Extra udev rules for ITE 8258 RGB HID controller to ensure immediate 0666 access
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="048d", ATTRS{idProduct}=="c195", MODE="0666", TAG+="uaccess", GROUP="users"
  '';

  # Ensure all components (legionspace GUI, legionctl, legion-cli) are available in system profile
  environment.systemPackages = [
    legionPkg
  ];
}
