# ╭──────────────────────────────────────────────────────────╮
# │ Homebrew Configuration                                   │
# ╰──────────────────────────────────────────────────────────╯
#
# Homebrew casks and brews managed by nix-darwin.

{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    taps = [
      "yakitrak/yakitrak"
    ];

    casks = [
      # Core apps
      "1password"
      "raycast"
      "visual-studio-code"
      "ghostty"

      # Fonts
      "font-monaspace"
    ];

    brews = [
      "yakitrak/yakitrak/obsidian-cli"
    ];
  };
}
