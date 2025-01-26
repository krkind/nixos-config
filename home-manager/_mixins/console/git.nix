{ darkmode, ... }: {
  programs = {
    git = {
      enable = true;
      delta = {
        enable = true;
        options = {
          features = "decorations";
          navigate = true;
          side-by-side = true;
          light = !darkmode;
        };
      };
      aliases = {
        adog = "log --all --decorate --oneline --graph";
        co = "checkout";
      };
      userEmail = "kristian.kinderlov@airolit.com";
      userName = "Kristian Kinderlöv";
      extraConfig = {
        push = {
          default = "matching";
        };
        pull = {
          rebase = true;
        };
        init = {
          defaultBranch = "master";
        };
      };
    };
  };
}
