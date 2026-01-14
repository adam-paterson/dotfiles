# ╭──────────────────────────────────────────────────────────╮
# │ Home Manager Base Configuration                          │
# ╰──────────────────────────────────────────────────────────╯
#
# Core configuration shared by all platforms.

{
  lib,
  pkgs,
  userConfig,
  ...
}:

{
  xdg.enable = true;

  home = {
    username = lib.mkDefault userConfig.username;
    homeDirectory = lib.mkDefault (
      if pkgs.stdenv.isDarwin then userConfig.homeDirectory.darwin else userConfig.homeDirectory.linux
    );

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    sessionPath = [
      "$HOME/.bun/bin"
    ];

    packages = with pkgs; [
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
  };

  # ── Enable Tool Modules ───────────────────────────────────────────────────
  tools = {
    opencode.enable = true;
    git.enable = true;
    neovim.enable = true;
    tmux.enable = true;
  };

  # ── Programs ─────────────────────────────────────────────────────────────────
  programs = {
    home-manager.enable = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    bat = {
      enable = true;
      config.theme = "TwoDark";
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    lazygit.enable = true;
  };
}
