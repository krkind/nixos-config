{ lib, ... }:
{
  imports = [
    ../_mixins/services/tailscale.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
