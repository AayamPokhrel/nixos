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
      jq
      yq-go
      ripgrep
      fd
      tree
      cpio
      lz4
      dtc
      simg2img
      protobuf

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

    extraOutputsToInstall = [ "dev" ];

    extraBuildCommands = ''
      mkdir -p $out/usr/lib64/x86_64-linux-gnu
      mkdir -p $out/usr/include/x86_64-linux-gnu
      mkdir -p $out/usr/lib64/gcc/x86_64-linux-gnu
      mkdir -p $out/usr/lib64/gcc/x86_64-unknown-linux-gnu

      # Link GCC runtime objects and static libgcc into /usr/lib64 (and /usr/lib)
      ln -s ${pkgs.gcc.cc}/lib/gcc/*/*/*.o $out/usr/lib64/
      ln -s ${pkgs.gcc.cc}/lib/gcc/*/*/*.a $out/usr/lib64/

      # Link the GCC toolchain directory for compiler autodetect
      ln -s ${pkgs.gcc.cc}/lib/gcc/*/* $out/usr/lib64/gcc/x86_64-linux-gnu/${pkgs.gcc.version}
      ln -s ${pkgs.gcc.cc}/lib/gcc/*/* $out/usr/lib64/gcc/x86_64-unknown-linux-gnu/${pkgs.gcc.version}
    '';

    runScript = "bash";

    profile = ''
      export LC_ALL=C
      export USE_CCACHE=1
      export CCACHE_DIR="$HOME/.cache/ccache"
      mkdir -p "$CCACHE_DIR"
      export CCACHE_EXEC=$(which ccache 2>/dev/null || true)
      export ALLOW_NINJA_ENV=true
      export LIBRARY_PATH="${pkgs.gcc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${pkgs.gcc.version}:$LIBRARY_PATH"
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    android-env
    android-tools
    ccache
    erofs-utils
    scrcpy
    android-studio

    # Android ROM, Kernel, Partition & System App Build Utilities
    aapt
    apksigner
    bundletool
    payload-dumper-go
    simg2img
    dtc
    lz4
    squashfsTools
    android-backup-extractor
    protobuf
    jq
    yq-go
    fd
    file
    usbutils
    picocom

    # Prebuilt MCP Servers for Antigravity
    mcp-nixos
    context7-mcp
    mcp-server-git
    mcp-server-fetch
    mcp-server-sequential-thinking
    mcp-server-memory
  ];
}
