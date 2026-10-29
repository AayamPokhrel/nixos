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
            (final: prev: {
              jetbrains-toolbox =
                let
                  version = "3.9.0.88839";
                  src = prev.fetchzip {
                    url = "https://download.jetbrains.com/toolbox/jetbrains-toolbox-${version}.tar.gz";
                    hash = "sha256-Nqov5++wuLy4r08N6inyBmdr9eTdQknrc1AFf0jywTs=";
                  };
                in
                prev.buildFHSEnv {
                  pname = "jetbrains-toolbox";
                  inherit version;
                  meta = prev.jetbrains-toolbox.meta // {
                    mainProgram = "jetbrains-toolbox";
                  };
                  multiPkgs =
                    p:
                    with p;
                    [
                      icu
                      libappindicator
                    ]
                    ++ prev.appimageTools.defaultFhsEnvArgs.multiPkgs p;
                  runScript = "${src}/bin/jetbrains-toolbox --update-failed";
                  extraInstallCommands = ''
                    install -Dm0644 ${src}/bin/jetbrains-toolbox.desktop -t $out/share/applications
                    install -Dm0644 ${src}/bin/toolbox-tray-color.png $out/share/icons/hicolor/32x32/apps/jetbrains-toolbox.png
                  '';
                };
            })
          ];
        }
        ./configuration.nix
      ];
    };
  };
}
