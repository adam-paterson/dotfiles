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
        _FXSortFoldersFirst = true;
        FXDefaultSearchScope = "SCcf"; # Search current folder
        FXEnableExtensionChangeWarning = false;
        ShowExternalHardDrivesOnDesktop = false;
        ShowRemovableMediaOnDesktop = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3; # Full keyboard access
        ApplePressAndHoldEnabled = false;
        AppleScrollerPagingBehavior = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
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

    keyboard = {
      enableKeyMapping = true;

      # Remap ISO Section key (§/±) to Grave Accent/Tilde (`/~)
      # This fixes external keyboards like Keychron Q1 that send ISO scancode
      # 0x64 (ISO Section) instead of 0x35 (Grave Accent)
      userKeyMapping = [
        {
          # ISO Section key (§/±) -> Grave Accent/Tilde (`/~)
          HIDKeyboardModifierMappingSrc = 30064771172; # 0x700000064
          HIDKeyboardModifierMappingDst = 30064771125; # 0x700000035
        }
      ];
    };

    activationScripts.screenshotsDir.text = ''
      mkdir -p ~/Pictures/Screenshots
    '';
  };
}
