{ darkmode, ... }: {
  programs = {
    git = {
      enable = true;
      settings = {
        alias = {
          adog = "log --all --decorate --oneline --graph";
          lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
          co = "checkout";
          ci = "commit";
          st = "status";
          br = "branch";
        };
        user = {
          email = "kristian.kinderlov@airolit.com";
          name = "Kristian Kinderlöv";
        };
        push = {
          default = "matching";
        };
        pull = {
          rebase = true;
        };
        init = {
          defaultBranch = "master";
        };
        merge = {
          tool = "meld";
        };
        mergetool = {
          prompt = false;
        };
      };
    };
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        features = "decorations";
        navigate = true;
        side-by-side = true;
        light = !darkmode;
      };
    };
  };
}
