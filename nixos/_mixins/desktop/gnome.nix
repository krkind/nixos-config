{ ... }: {
  imports = [
  ];

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb.layout = "se";  # Sets Swedish keyboard layout
}
