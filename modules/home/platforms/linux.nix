# ╭──────────────────────────────────────────────────────────╮
# │ Linux Home Manager Configuration                         │
# ╰──────────────────────────────────────────────────────────╯
#
# Linux-specific home-manager configuration.

{ lib, pkgs, ... }:
{
  # ── Linux-Specific Packages ───────────────────────────────────────────────
  home.packages = with pkgs; [
    xclip
    xsel
  ];

  # ── Linux-Specific Shell Config ───────────────────────────────────────────
  programs.zsh.initContent = lib.mkAfter ''
    # pbcopy/pbpaste equivalents
    if command -v xclip >/dev/null 2>&1; then
      alias pbcopy="xclip -selection clipboard -i"
      alias pbpaste="xclip -selection clipboard -o"
    fi
  '';

  # ── Linux-Specific Git ────────────────────────────────────────────────────
  programs.git.settings.credential.helper = "store";
}
