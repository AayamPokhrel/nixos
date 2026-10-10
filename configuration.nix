{ config, pkgs, ... }:

let
  # FHS container environment for Android ROM and kernel compilation
  android-env = pkgs.buildFHSEnv {
    name = "android-env";
    targetPkgs = pkgs: with pkgs; [
      # Core build systems & utilities
      git
      git-repo
      git-lfs
      gnupg
      flex
      bison
      gperf
      gcc
      gnumake
      binutils
      patch
      diffutils
      cmake
      ninja
      pkg-config
      autoconf
      automake
      libtool
      fakeroot
      schedtool
      procps
      psmisc
      which
      file
      bc
      rsync
      zip
      unzip
      curl
      wget
      nettools

      # Compilers, runtimes & Python packages
      clang
      llvmPackages.bintools
      jdk
      python3
      python3Packages.pip
      python3Packages.pyelftools

      # Headers & libraries
      glibc.dev
      libgcc
      zlib
      openssl
      libxml2
      fontconfig
      freetype
      elfutils
      ncurses
      libxcrypt-legacy
    ];

    # 32-bit compatibility libraries required by legacy toolchains and prebuilts
    multiPkgs = pkgs: with pkgs; [
      zlib
      ncurses
      libxcrypt-legacy
    ];

    runScript = "bash";

    profile = ''
      export LC_ALL=C
      export USE_CCACHE=1
      export ANDROID_BUILD_TOP="$(pwd)"
    '';
  };
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader & Kernel
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Localization & Time
  time.timeZone = "Asia/Kathmandu";
  i18n.defaultLocale = "en_US.UTF-8";

  # Desktop Environment (GNOME)
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Native browser connector for extensions.gnome.org
  services.gnome.gnome-browser-connector.enable = true;

  # Enable Flatpak support so GNOME Software can install graphical apps
  services.flatpak.enable = true;

  # Printing
  services.printing.enable = true;

  # Audio (PipeWire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User Account
  users.users."aayam422h" = {
    isNormalUser = true;
    description = "aayam422h";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Shell and default programs
  programs.zsh.enable = true;
  programs.firefox.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Allow proprietary packages
  nixpkgs.config.allowUnfree = true;

  # System-wide packages
  environment.systemPackages = with pkgs; [

    # Audio
    jamesdsp
    # Custom environments & Android tools
    android-env
    android-tools

    # GNOME Management & Customization
    gnomeExtensions.appindicator # Tray notifier 
    gnome-software           # GNOME Software store
    gnome-extension-manager  # Offline/GUI extension browser & manager
    gnome-tweaks             # Classic GNOME Tweaks
    refine                   # Modern GNOME Refine tool

    # General utilities & editors
    vim
    neovim
    fastfetch
    tmux
    tree
    wget
    curl
    google-chrome
    telegram-desktop

    # Development & version control
    git
    git-repo
    git-lfs
    gh

    # Build tools & compilers
    clang
    gcc
    gnumake
    binutils
    patch
    cmake
    ninja
    pkg-config
    fakeroot
    autoconf
    automake
    libtool

    # Languages & Runtimes
    python3
    jdk
    maven
    gradle
  ];

# Load all nerd fonts
fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ] ++ (builtins.filter pkgs.lib.isDerivation (builtins.attrValues pkgs.nerd-fonts));

  # System services
  services.openssh.enable = true;

  # Flakes and new CLI tool support
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # State version
  system.stateVersion = "26.05";
}
