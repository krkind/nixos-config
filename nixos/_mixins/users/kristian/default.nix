{ config, desktop, lib, pkgs, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  # Only include desktop components if one is supplied.
  imports = [ ] ++ lib.optional (builtins.isString desktop) ./desktop.nix;

  environment.systemPackages = with pkgs; [
    vim
    wget
    gitFull
  ];

  users.users.kristian = {
    isNormalUser = true;
    initialPassword = "ripxonix";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZP3esepBaHz0rZhWm8DExJ/u83zcrRw2pU/7+HfWiZ kristian.kinderlov@airolit.com"
    ];
    extraGroups = [
      "wheel"
      "dialout"
      "plugdev"
      "audio"
      "video"
    ] # Enable ‘sudo’ for the user.
    ++ ifExists [
      "docker"
      "podman"
      "jellyfin"
      "wireshark"
      "libvirtd"
      "adbusers"
    ];
    packages = with pkgs; [
      firefox
      tree
    ];
    shell = pkgs.zsh;
  };
}
