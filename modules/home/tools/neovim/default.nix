# ╭──────────────────────────────────────────────────────────╮
# │ Neovim Module                                            │
# ╰──────────────────────────────────────────────────────────╯
#
# Neovim editor configuration.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.tools.neovim;
in
{
  options.tools.neovim = {
    enable = lib.mkEnableOption "Neovim configuration";

    defaultEditor = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set Neovim as default editor";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = cfg.defaultEditor;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      # Add basic packages for LSP, treesitter, etc.
      extraPackages = with pkgs; [
        # Language servers
        nil # Nix
        nodePackages.typescript-language-server
        lua-language-server

        # Tools
        ripgrep
        fd
        tree-sitter
      ];
    };

    # You can add custom neovim configuration here
    # xdg.configFile."nvim" = { ... };
  };
}
