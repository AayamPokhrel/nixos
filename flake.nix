{
  description = "System Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    libdisplay-info-src = {
      url = "git+https://gitlab.freedesktop.org/emersion/libdisplay-info.git?ref=main";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, libdisplay-info-src, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
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
        ./configuration.nix
      ];
    };
  };
}
