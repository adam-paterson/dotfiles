# ╭──────────────────────────────────────────────────────────╮
# │ Home Manager Modules                                     │
# ╰──────────────────────────────────────────────────────────╯
#
# Auto-imports all home-manager modules.

{ ... }:
{
  imports = [
    ./base.nix
    ./shell
    ./tools/opencode
    ./tools/git
    ./tools/neovim
    ./tools/tmux
  ];
}
