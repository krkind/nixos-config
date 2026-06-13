# Krkinds Work Computer
{ config, lib, pkgs, ... }:

{
  imports = [
    ../_mixins/services/tailscale.nix
    ../_mixins/services/syncthing.nix
    ../_mixins/services/flatpak.nix
    ../_mixins/services/pipewire.nix
    ../_mixins/virt
    ../_mixins/streaming
  ];

  # Overrides for virt (specifically windows 11 support)
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };
  };

  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };

    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  # hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Bootloader.
  boot.loader.systemd-boot.enable = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "rndis_host" "cdc_ether" ];
  boot.kernelParams = [ "i915.force_probe=7d55" ];  # Needed for proper installation of Intel Arc firmware
  boot.extraModulePackages = [ ];

  services.envfs.enable = true;
  services.printing.enable = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d92095ff-a062-4c6f-8022-bac98f45e96d";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F256-A388";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/bd16cd13-cca1-4346-a7e1-adca8a3643d7"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # hardware.enableRedistributableFirmware = true;

  # In order for VSCode remote to work
  programs.nix-ld.enable = true;
  # programs.talon.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "segger-jlink"
    "segger-ozone"
  ];

  nixpkgs.config.segger-jlink.acceptLicense = true;

  services.udev.packages = [ pkgs.segger-jlink-headless ];

  assertions = [
    {
      assertion = pkgs.unstable.kicad.version == "10.0.3";
      message = "Expected pkgs.unstable.kicad.version to be 10.0.3, got ${pkgs.unstable.kicad.version}; update nixpkgs-unstable pin or adjust this assertion.";
    }
  ];

  environment.systemPackages = with pkgs; [
    android-tools
    segger-jlink-headless
    segger-ozone
    # obs-studio
    # remmina
    unstable.kicad
    # kicad
    # prusa-slicer
    wireshark
    # reaper
    teams-for-linux
    # yabridge
    # yabridgectl
    # wineWowPackages.unstable
    # winetricks
    # tuxguitar
    # moonlight-qt
    # linuxPackages.usbip
    # wakeonlan
    # distrobox
    # samba
    meld
    claude-code
    zellij
    git-lfs
    signal-desktop
    mqtt-explorer
    (pkgs.python3.withPackages (ps: with ps; [ pyserial python-lsp-server ]))
  ];

  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.permittedInsecurePackages = [ "docker-28.5.2" ];

  security.wrappers.dumpcap = {
    source = "${pkgs.wireshark}/bin/dumpcap";
    owner = "root";
    group = "wireshark";
    capabilities = "cap_net_raw,cap_net_admin+eip";
  };

  users.groups.wireshark = { };
}
