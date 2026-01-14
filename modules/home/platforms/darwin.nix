# ╭──────────────────────────────────────────────────────────╮
# │ macOS Home Manager Configuration                         │
# ╰──────────────────────────────────────────────────────────╯
#
# macOS-specific home-manager configuration.

{ lib, pkgs, ... }:
{
  # ── macOS-Specific Home Settings ─────────────────────────────────────────────
  home = {
    packages = with pkgs; [
      mas # Mac App Store CLI
      darwin.trash # Move to trash instead of rm
    ];

    sessionPath = [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];

    sessionVariables = {
      HOMEBREW_NO_ANALYTICS = "1";
    };
  };

  # ── macOS-Specific Programs ──────────────────────────────────────────────────
  programs = {
    zsh.initContent = lib.mkAfter ''
      # Homebrew completions
      if type brew &>/dev/null; then
        FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
      fi
    '';

    git.settings.credential.helper = "osxkeychain";
  };
}
