{ lib, ... }: {
  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = lib.mkDefault "no";
      };
    };
  };
  programs.ssh.startAgent = false;
  networking.firewall.allowedTCPPorts = [ 22 ];
}
