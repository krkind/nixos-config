{ desktop, ... }: {
  imports = [
    (./. + "/${desktop}.nix")
  ];
}
