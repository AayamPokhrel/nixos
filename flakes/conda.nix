{ config, pkgs, ... }:

let
  antigravityFlake = builtins.getFlake "github:jacopone/antigravity-nix";
in
{
  # Permanently enable flakes so builtins.getFlake works on future rebuilds
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.overlays = [ antigravityFlake.overlays.default ];

  environment.systemPackages = with pkgs; [
    conda
  ];
}