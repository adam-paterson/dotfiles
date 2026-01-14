# ╭──────────────────────────────────────────────────────────╮
# │ Git Module                                               │
# ╰──────────────────────────────────────────────────────────╯
#
# Git configuration with signing support.

{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = config.tools.git;
in
{
  options.tools.git = {
    enable = lib.mkEnableOption "Git configuration";

    signing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable commit signing";
      };

      key = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "SSH signing key";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      git
      gh
    ];

    programs.git = {
      enable = true;

      ignores = [
        ".DS_Store"
        "*.swp"
        ".direnv/"
        ".envrc"
        "*.backup"
      ];

      settings = {
        user = {
          name = userConfig.fullName;
          inherit (userConfig) email;
        };
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
        core.editor = "nvim";
        rerere.enabled = true;

        # Delta for better diffs
        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
          light = false;
          side-by-side = true;
        };
        merge.conflictStyle = "diff3";
        diff.colorMoved = "default";
      };
    };

    # GitHub CLI
    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
  };
}
