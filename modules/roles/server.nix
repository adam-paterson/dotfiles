# ╭──────────────────────────────────────────────────────────╮
# │ Server Role                                              │
# ╰──────────────────────────────────────────────────────────╯
#
# Minimal configuration for server machines.
# No GUI tools, focused on efficiency.

{ pkgs, ... }:
{
  # ── Server Packages ───────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Server utilities
    htop
    ncdu
  ];

  # ── Server-Specific Settings ──────────────────────────────────────────────
  # Disable some features not needed on servers
}
