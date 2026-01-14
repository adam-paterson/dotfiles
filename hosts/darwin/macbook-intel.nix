# ╭──────────────────────────────────────────────────────────╮
# │ MacBook Intel Configuration                              │
# ╰──────────────────────────────────────────────────────────╯
#
# Template configuration for Intel MacBook.
# This is a template host - builds but not actively deployed.

{ hostConfig, ... }:
{
  # ── Hostname ──────────────────────────────────────────────────────────────
  networking.hostName = hostConfig.hostname;

  # ── Intel-Specific Settings ───────────────────────────────────────────────
  # Homebrew path is different on Intel Macs
  # homebrew.brewPrefix = "/usr/local";
}
