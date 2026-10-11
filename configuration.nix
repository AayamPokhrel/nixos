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
      ccache

      # Partition & blob extraction tools (provides fsck.erofs)
      erofs-utils
      e2fsprogs
      brotli

      # Compilers, runtimes & Python packages
      clang
      llvmPackages.bintools
      jdk
      python3
      python3Packages.pip
      python3Packages.pyelftools

      # Headers & libraries
      glibc.dev
      glibc.static
      libgcc
      zlib
      openssl
      libxml2
      fontconfig
      freetype
      elfutils
      ncurses
      ncurses5
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
      export CCACHE_EXEC=$(which ccache 2>/dev/null || true)
      export ALLOW_NINJA_ENV=true
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

  # Kernel parameters for HDR and DRM modesetting:
  # - amdgpu.dcdebugmask=0x10 exposes modern 3D LUT and color management blocks to Wayland
  # - nvidia-drm.modeset=1 enables DRM KMS for the NVIDIA driver
  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x10"
    "nvidia-drm.modeset=1"
  ];

  # CPU Microcode & Firmware
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # Hardware Acceleration & Vulkan (64-bit and 32-bit)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
    ];
  };

  # NVIDIA Driver Stack
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    # Uses open-source kernel modules (recommended for Turing, Ada Lovelace, and Blackwell architectures)
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # PRIME Offload (Optional):
    # If running hybrid graphics where the AMD iGPU powers the laptop screen,
    # run `lspci | grep -E "VGA|3D"` to get your PCI bus IDs and uncomment below:
    # prime = {
    #   offload.enable = true;
    #   offload.enableOffloadCmd = true;
    #   amdgpuBusId = "PCI:5:0:0";  # Replace with your AMD iGPU PCI ID
    #   nvidiaBusId = "PCI:1:0:0";  # Replace with your NVIDIA dGPU PCI ID
    # };
  };

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

  # Color Management Daemon (required for accurate HDR tone mapping and ICC profiles)
  services.colord.enable = true;

  # Native browser connector for extensions.gnome.org
  services.gnome.gnome-browser-connector.enable = true;

  # Flatpak
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
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };

  # Shell and default programs
  programs.zsh.enable = true;
  programs.firefox.enable = true;
  programs.dconf.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Allow unfree packages (VS Code, NVIDIA drivers, Google Chrome)
  nixpkgs.config.allowUnfree = true;

  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Audio
    jamesdsp

    # Custom environments & Android tools
    android-env
    android-tools
    erofs-utils

    # GNOME Management & Customization
    gnomeExtensions.appindicator
    gnome-software
    gnome-extension-manager
    gnome-tweaks
    refine
    libgtop

    # General utilities, editors & IDEs
    vim
    neovim
    vscode
    fastfetch
    tmux
    tree
    wget
    curl
    google-chrome
    telegram-desktop

    # Graphics, Vulkan & Hardware inspection tools
    vulkan-tools
    libdrm
    pciutils
    clinfo

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

  # Fonts
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
