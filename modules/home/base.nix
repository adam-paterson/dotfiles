# ╭──────────────────────────────────────────────────────────╮
# │ Home Manager Base Configuration                          │
# ╰──────────────────────────────────────────────────────────╯
#
# Core configuration shared by all platforms.

{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:

{
  programs.home-manager.enable = true;
  xdg.enable = true;

  home = {
    username = lib.mkDefault userConfig.username;
    homeDirectory = lib.mkDefault (
      if pkgs.stdenv.isDarwin then userConfig.homeDirectory.darwin else userConfig.homeDirectory.linux
    );
  };

  # ── Enable Tool Modules ───────────────────────────────────────────────────
  tools = {
    opencode.enable = true;
    git.enable = true;
    neovim.enable = true;
    tmux.enable = true;
  };

  # ── Environment ───────────────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.sessionPath = [
    "$HOME/.bun/bin"
  ];

  # ── Packages ──────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Modern CLI tools
    eza
    bat
    ripgrep
    fd
    fzf
    jq
    yq
    delta
    dust
    htop
    btop
    tree
    tailspin

    # Development
    lazygit
    direnv
    bun

    # Utilities
    curl
    wget

    # AI Tools
    codex
  ];

  # ── Other Programs ────────────────────────────────────────────────────────
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat = {
    enable = true;
    config.theme = "TwoDark";
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.lazygit.enable = true;
}
