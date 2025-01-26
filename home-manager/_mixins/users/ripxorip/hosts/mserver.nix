{ lib, pkgs, ... }:
{
  imports = [ ];
  programs.git.extraConfig = {
    safe = {
      directory = "/home/kristian/dev/migic.com";
    };
  };
}
