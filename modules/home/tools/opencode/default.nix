# ╭──────────────────────────────────────────────────────────╮
# │ OpenCode Module                                          │
# ╰──────────────────────────────────────────────────────────╯
#
# AI-powered coding assistant configuration.
# Handles installation, environment variables, and config files.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.tools.opencode;
in
{
  options.tools.opencode = {
    enable = lib.mkEnableOption "OpenCode AI coding assistant";

    experimentalFeatures = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable experimental OpenCode features";
    };

    installViaBun = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install OpenCode via bun (for latest version)";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Package Installation ────────────────────────────────────────────────
    home.activation.installOpenCode = lib.mkIf cfg.installViaBun (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.bun}/bin/bun install -g opencode-ai 2>/dev/null || true
      ''
    );

    # ── Environment Variables ───────────────────────────────────────────────
    home.sessionVariables = lib.mkIf cfg.experimentalFeatures {
      OPENCODE_ENABLE_EXPERIMENTAL_MODELS = "1";
      OPENCODE_ENABLE_EXA = "1";
      OPENCODE_EXPERIMENTAL = "1";
    };

    # ── Configuration Files ─────────────────────────────────────────────────
    xdg.configFile = {
      "opencode/opencode.json".source = ./opencode.json;
      "opencode/skill" = {
        source = ./skills;
        recursive = true;
      };
    };

    # ── Shell Integration ───────────────────────────────────────────────────
    programs.zsh.shellAliases = {
      oc = "opencode";
    };
  };
}
