{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Compilers & Toolchains
    gcc
    clang
    binutils

    # Build Systems & Tools
    cmake
    ninja
    gnumake
    pkg-config
    libtool
    autoconf
    automake
    patch
    fakeroot

    # Version Control & Development utilities
    git-repo
    git-lfs
    gh

    # Languages & Runtimes
    python3
    jdk
    maven
    gradle
  ];
}
