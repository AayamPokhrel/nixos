{
  description = "System Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    libdisplay-info-src = {
      url = "git+https://gitlab.freedesktop.org/emersion/libdisplay-info.git?ref=main";
      flake = false;
    };
    ajazz-ak820-max = {
      url = "path:/home/aayam422h/AJAZ/ajazz-ak820-max";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, libdisplay-info-src, ajazz-ak820-max, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ajazz-ak820-max.nixosModules.default
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
