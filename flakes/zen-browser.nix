{ config, pkgs, ... }:

let
  zenBrowserFlake = builtins.getFlake "github:youwen5/zen-browser-flake";
in
{
  environment.systemPackages = [
    zenBrowserFlake.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
