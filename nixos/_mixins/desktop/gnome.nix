{ ... }: {
  imports = [
  ];

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.xkb.layout = "se";  # Sets Swedish keyboard layout
}
