# ╭──────────────────────────────────────────────────────────╮
# │ Darwin System Preferences                                │
# ╰──────────────────────────────────────────────────────────╯
#
# macOS system defaults and preferences.

_: {
  # ── System Configuration ─────────────────────────────────────────────────────
  system = {
    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        show-recents = false;
        tilesize = 48;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        FXDefaultSearchScope = "SCcf"; # Search current folder
        FXEnableExtensionChangeWarning = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3; # Full keyboard access
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };

      loginwindow.GuestEnabled = false;

      screencapture = {
        location = "~/Pictures/Screenshots";
        type = "png";
      };
    };

    keyboard.enableKeyMapping = true;

    activationScripts.screenshotsDir.text = ''
      mkdir -p ~/Pictures/Screenshots
    '';
  };
}
