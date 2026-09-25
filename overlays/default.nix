# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays

  modifications = final: prev: {
    segger-ozone = prev.segger-ozone.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ final.makeWrapper ];
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/Ozone \
          --prefix LD_LIBRARY_PATH : ${final.systemd}/lib
      '';
    });

    vimPlugins = prev.vimPlugins // rec {
      # nixpkgs pins this plugin to the mutable tag ref "refs/tags/v2.0.4", which
      # upstream re-pointed to a new commit, breaking the fixed-output hash.
      # Pin to the actual commit the tag currently points at instead.
      copilot-lua = prev.vimPlugins.copilot-lua.overrideAttrs (old: {
        src = final.fetchFromGitHub {
          owner = "zbirenbaum";
          repo = "copilot.lua";
          rev = "v2.0.4";
          hash = "sha256-05f76OeWBlFmlUh90tH4XMMKfNI1jnhuIJDqYPPQokA=";
        };
      });

      # These plugins' dependency lists are baked in via nixpkgs' internal
      # vim-plugin fixpoint, so they still pull the broken copilot-lua unless
      # we repoint them here too.
      CopilotChat-nvim = prev.vimPlugins.CopilotChat-nvim.overrideAttrs (old: {
        dependencies = [
          copilot-lua
          prev.vimPlugins.plenary-nvim
        ];
      });

      copilot-cmp = prev.vimPlugins.copilot-cmp.overrideAttrs (old: {
        dependencies = [ copilot-lua ];
      });
    };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
}
