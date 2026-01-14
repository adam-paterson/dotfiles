# ╭──────────────────────────────────────────────────────────╮
# │ Darwin Modules                                           │
# ╰──────────────────────────────────────────────────────────╯
#
# Auto-imports all darwin system modules.

{ ... }:
{
  imports = [
    ./base.nix
    ./system.nix
    ./homebrew.nix
  ];
}
