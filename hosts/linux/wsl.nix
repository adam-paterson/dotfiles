# ╭──────────────────────────────────────────────────────────╮
# │ WSL Configuration                                        │
# ╰──────────────────────────────────────────────────────────╯
#
# Template configuration for Windows Subsystem for Linux.
# This is a template host - builds but not actively deployed.

{ hostConfig, ... }:
{
  # ── WSL-Specific Settings ─────────────────────────────────────────────────
  # Most WSL config is in modules/home/platforms/wsl.nix
  # Add any machine-specific WSL settings here

  # Example: customize Windows username if different
  # programs.zsh.shellAliases.code =
  #   "/mnt/c/Users/YOUR_WINDOWS_USER/AppData/Local/Programs/Microsoft VS Code/bin/code";
}
