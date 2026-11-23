{ config, lib, pkgs, ... }:

let
  ajazzFlake = builtins.getFlake "git+https://github.com/AayamPokhrel/AJAZZ_AK820MAX_LINUX_DRIVER.git";
in
{
  imports = [
    ajazzFlake.nixosModules.default
  ];

  # Ajazz AK820 Max Native Linux Driver & RGB Music Visualizer (GUI, CLI, daemon, udev rules)
  hardware.ajazz-ak820-max.enable = true;
  hardware.ajazz-ak820-max.daemon.enable = true;

  # Ensure all components (ak820-gui, ak820ctl, ak820d) are available in system profile
  environment.systemPackages = [
    ajazzFlake.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
