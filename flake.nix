{
  description = "System Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    libdisplay-info-src = {
      url = "git+https://gitlab.freedesktop.org/emersion/libdisplay-info.git?ref=main";
      flake = false;
    };
    toolbox = {
      url = "path:./toolbox";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ajazz-ak820-max = {
      url = "path:/home/aayam422h/AJAZ/ajazz-ak820-max";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    legion-linux = {
      url = "path:/home/aayam422h/Legion_Space";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { legion-linux,  self, nixpkgs, libdisplay-info-src, ajazz-ak820-max, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        legion-linux.nixosModules.default
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
