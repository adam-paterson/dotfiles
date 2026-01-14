# ╭──────────────────────────────────────────────────────────╮
# │ WSL2 Home Manager Configuration                          │
# ╰──────────────────────────────────────────────────────────╯
#
# Windows Subsystem for Linux specific configuration.
# Extends Linux config with Windows integration.

{ lib, pkgs, ... }:
{
  # Import base linux config
  imports = [ ./linux.nix ];

  # ── WSL-Specific Home Settings ───────────────────────────────────────────────
  home = {
    packages = with pkgs; [
      wl-clipboard # Wayland clipboard (WSLg)
      wslu # WSL utilities
    ];

    sessionVariables = {
      BROWSER = "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe";
    };
  };

  # ── WSL-Specific Programs ────────────────────────────────────────────────────
  programs = {
    zsh = {
      shellAliases = {
        open = "wslview";
        explorer = "explorer.exe";
        # Update path to your VS Code installation
        code = "/mnt/c/Users/adampaterson/AppData/Local/Programs/Microsoft VS Code/bin/code";
      };

      initContent = lib.mkAfter ''
        # Add Windows paths for common utilities
        export PATH="$PATH:/mnt/c/Windows/System32"

        # WSL-specific clipboard handling
        if command -v clip.exe >/dev/null 2>&1; then
          alias pbcopy="clip.exe"
          alias pbpaste="powershell.exe -command 'Get-Clipboard' | head -n -1"
        fi
      '';
    };

    git.settings = lib.mkForce {
      credential.helper = "/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe";
    };
  };
}
