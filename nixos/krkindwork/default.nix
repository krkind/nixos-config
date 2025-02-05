# Krkinds Work Computer
{ config, lib, pkgs, ... }:
{
  imports = [
    ../_mixins/services/tailscale.nix
    ../_mixins/services/syncthing.nix
    ../_mixins/services/flatpak.nix
    ../_mixins/services/pipewire.nix
    ../_mixins/virt
  ];

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  # hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
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
  programs.adb.enable = true;

  environment.systemPackages = with pkgs; [
    # obs-studio
    # remmina
    # kicad
    # prusa-slicer
    # wireshark
    # reaper
    # teams-for-linux
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
    (pkgs.python3.withPackages (ps: with ps; [ pyserial python-lsp-server ]))
  ];
}
