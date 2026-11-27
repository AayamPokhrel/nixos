{ config, pkgs, ... }:

let
  rePython = pkgs.python3.withPackages (ps: with ps; [
    mcp
    fastmcp
    r2pipe
    rzpipe
    pyelftools
    capstone
    unicorn
    keystone-engine
    lief
    frida-python
    cryptography
    protobuf
  ]);

  # Wrapper executable avoids colliding with development.nix's python3 in /run/current-system/sw/bin
  rePythonBin = pkgs.writeShellScriptBin "re-python3" ''
    exec ${rePython}/bin/python3 "$@"
  '';
in
{
  programs.wireshark = {
    enable = true;
    dumpcap.enable = true;
  };

  users.users."legion".extraGroups = [ "wireshark" ];

  environment.systemPackages = with pkgs; [
    # Android APK / DEX / Smali Reverse Engineering
    jadx
    apktool
    dex2jar
    apkid
    apkleaks
    apkeditor
    apksigcopier

    # Native Binary / ELF / Kernel / Firmware Reverse Engineering
    ghidra-bin
    radare2
    rizin
    cutter
    imhex
    binwalk
    patchelf
    elfutils
    gdb
    lldb
    ltrace
    strace
    vmlinux-to-elf
    yara
    sqlite
    openssl

    # Dynamic Instrumentation & Traffic Analysis
    frida-tools
    mitmproxy

    # Scripting & MCP runtimes
    nodejs
    uv
    rePythonBin
  ];
}
