# ╭──────────────────────────────────────────────────────────╮
# │ macOS Home Manager Configuration                         │
# ╰──────────────────────────────────────────────────────────╯
#
# macOS-specific home-manager configuration.

{ lib, pkgs, ... }:
{
  # ── macOS-Specific Packages ───────────────────────────────────────────────
  home.packages = with pkgs; [
    mas # Mac App Store CLI
    darwin.trash # Move to trash instead of rm
  ];

  # ── macOS-Specific Paths ──────────────────────────────────────────────────
  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  # ── macOS-Specific Environment ────────────────────────────────────────────
  home.sessionVariables = {
    HOMEBREW_NO_ANALYTICS = "1";
  };

  # ── macOS-Specific Shell Config ───────────────────────────────────────────
  programs.zsh.initContent = lib.mkAfter ''
    # Homebrew completions
    if type brew &>/dev/null; then
      FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
    fi
  '';

  # ── macOS-Specific Git ────────────────────────────────────────────────────
  programs.git.settings.credential.helper = "osxkeychain";
}
