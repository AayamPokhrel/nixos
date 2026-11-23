{ config, pkgs, ... }:

let
  libdisplay-info-src = builtins.fetchGit {
    url = "https://gitlab.freedesktop.org/emersion/libdisplay-info.git";
    ref = "main";
  };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      libdisplay-info = prev.libdisplay-info.overrideAttrs (oldAttrs: {
        version = oldAttrs.version;
        src = libdisplay-info-src;
      });
    })
  ];
}
