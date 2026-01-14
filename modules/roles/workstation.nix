# ╭──────────────────────────────────────────────────────────╮
# │ Workstation Role                                         │
# ╰──────────────────────────────────────────────────────────╯
#
# Configuration for workstation machines (desktops, laptops).
# Includes GUI tools and full development environment.

{ pkgs, ... }:
{
  # ── Workstation Packages ──────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Additional dev tools for workstations
    nodejs_22
    typescript

    # More utilities
    httpie
    glow # Markdown preview
  ];

  # ── Workstation-Specific Settings ─────────────────────────────────────────
  # Add any workstation-specific configuration here
}
