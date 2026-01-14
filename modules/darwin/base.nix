# ╭──────────────────────────────────────────────────────────╮
# │ Darwin Base Configuration                                │
# ╰──────────────────────────────────────────────────────────╯
#
# Core nix-darwin settings shared by all macOS hosts.

{ pkgs, userConfig, ... }:
{
  # ── Nix Settings ──────────────────────────────────────────────────────────
  # Disable nix-darwin's Nix management (using Determinate Systems installer)
  nix.enable = false;
  nixpkgs.config.allowUnfree = true;

  # ── System ────────────────────────────────────────────────────────────────
  system.primaryUser = userConfig.username;

  # Used for backwards compatibility
  system.stateVersion = 6;

  # ── Shell ─────────────────────────────────────────────────────────────────
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  users.users.${userConfig.username} = {
    shell = pkgs.zsh;
    home = userConfig.homeDirectory.darwin;
  };

  # ── Security ──────────────────────────────────────────────────────────────
  security.pam.services.sudo_local.touchIdAuth = true;

  # ── System Packages ───────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    vim
    git
  ];
}
