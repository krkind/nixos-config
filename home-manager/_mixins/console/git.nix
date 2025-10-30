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
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        co = "checkout";
        ci = "commit";
        st = "status";
        br = "branch";
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
