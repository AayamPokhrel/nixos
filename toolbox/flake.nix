{
  description = "JetBrains Toolbox and runtime environment for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          version = "3.9.0.88839";
          src = pkgs.fetchzip {
            url = "https://download.jetbrains.com/toolbox/jetbrains-toolbox-${version}.tar.gz";
            hash = "sha256-Nqov5++wuLy4r08N6inyBmdr9eTdQknrc1AFf0jywTs=";
          };
        in {
          jetbrains-toolbox = pkgs.buildFHSEnv {
            pname = "jetbrains-toolbox";
            inherit version;
            meta = pkgs.jetbrains-toolbox.meta // {
              mainProgram = "jetbrains-toolbox";
            };
            multiPkgs = p: with p; [
              icu
              libappindicator
            ] ++ pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs p;
            runScript = "${src}/bin/jetbrains-toolbox --update-failed";
            extraInstallCommands = ''
              install -Dm0644 ${src}/bin/jetbrains-toolbox.desktop -t $out/share/applications
              install -Dm0644 ${src}/bin/toolbox-tray-color.png $out/share/icons/hicolor/32x32/apps/jetbrains-toolbox.png
            '';
          };
          default = self.packages.${system}.jetbrains-toolbox;
        }
      );

      nixosModules = rec {
        default = toolbox;
        toolbox = { config, pkgs, ... }: {
          # Allow unfree packages
          nixpkgs.config.allowUnfree = true;

          # System package for JetBrains Toolbox
          environment.systemPackages = [
            self.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];

          # Dynamic linker configuration with all runtime libraries required by JetBrains IDEs
          programs.nix-ld = {
            enable = true;
            libraries = with pkgs; [
              stdenv.cc.cc
              zlib
              glib
              openssl
              icu
              util-linux

              # X11 & Graphics libraries for JetBrains Runtime (AWT / Swing)
              libx11
              libxext
              libxi
              libxrender
              libxtst
              libxrandr
              libxcursor
              libxfixes
              libxcomposite
              libxdamage
              libxinerama
              libxcb
              libxshmfence
              libxscrnsaver

              # Font rendering
              freetype
              fontconfig

              # Audio & Input
              alsa-lib
              libxkbcommon

              # Wayland support
              wayland

              # OpenGL / Vulkan hardware acceleration
              libGL
              mesa
              vulkan-loader

              # Desktop & Secret service integration
              libsecret
              libnotify
              cups
              e2fsprogs
            ];
          };
        };
      };
    };
}
