{ config, pkgs, ... }: {
  imports = [
    ./tmux.nix
    ./zsh.nix
    ./git.nix
    ./nvim
  ];
  home = {
    file = {
      "${config.xdg.configHome}/starship.toml".text = builtins.readFile ./starship.toml;
    };

    packages = with pkgs; [
      starship
      fzf
      neofetch
      ripgrep
      exa
      fd
      bat
      delta
      btop
      tmux
      age
      bitwarden-cli
      key_extractor
    ];

    sessionVariables = {
      EDITOR = "vim";
      SYSTEMD_EDITOR = "vim";
      VISUAL = "vim";
    };
  };

  programs.starship = {
    enable = false;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
