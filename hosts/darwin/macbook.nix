# ╭──────────────────────────────────────────────────────────╮
# │ MacBook Configuration                                    │
# ╰──────────────────────────────────────────────────────────╯
#
# Configuration for personal MacBook (Apple Silicon).

{ hostConfig, ... }:
{
  # ── Hostname ──────────────────────────────────────────────────────────────
  networking.hostName = hostConfig.hostname;

  # ── Host-Specific Homebrew ────────────────────────────────────────────────
  # Add any host-specific casks/brews here
  # homebrew.casks = [ ];
}
