{ config, lib, pkgs, ... }:

let
  legionFlake = builtins.getFlake "git+ssh://git@github.com/AayamPokhrel/LegionSpace4Linux.git";
in
{
  imports = [
    legionFlake.nixosModules.default
  ];

  # Lenovo Legion hardware control driver, legionctl, legionspace, legion-cli, udev rules & kernel modules
  hardware.lenovo-legion.enable = true;

  # Ensure all components (legionspace, legionctl, legion-cli) are available in system profile
  environment.systemPackages = [
    legionFlake.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
