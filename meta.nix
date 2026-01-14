# ╭──────────────────────────────────────────────────────────╮
# │ Configuration Metadata                                   │
# ╰──────────────────────────────────────────────────────────╯
#
# Central configuration for users, hosts, and system settings.
# This file is imported by flake.nix and passed to all modules.

{
  # ── Users ────────────────────────────────────────────────────────────────
  users = {
    primary = {
      username = "adampaterson";
      fullName = "Adam Paterson";
      email = "adam@example.com"; # Update with real email
      githubUser = "adampaterson";
      homeDirectory = {
        darwin = "/Users/adampaterson";
        linux = "/home/adampaterson";
      };
    };

    # Future: work profile
    # work = {
    #   username = "adam.paterson";
    #   fullName = "Adam Paterson";
    #   email = "adam@company.com";
    #   homeDirectory = {
    #     darwin = "/Users/adam.paterson";
    #     linux = "/home/adam.paterson";
    #   };
    # };
  };

  # ── Hosts ────────────────────────────────────────────────────────────────
  hosts = {
    # ─── Active Hosts ───────────────────────────────────────────────────────
    macbook = {
      system = "aarch64-darwin";
      hostname = "MACBOOK-002531";
      role = "workstation";
      user = "primary";
      features = [ "development" "gui" ];
      description = "Personal MacBook (Apple Silicon)";
    };

    ubuntu-vps = {
      system = "x86_64-linux";
      hostname = "ubuntu-vps";
      role = "server";
      user = "primary";
      features = [ "development" ];
      description = "Ubuntu VPS";
      deploy = {
        host = "vps.example.com"; # Update with real host
        port = 22;
      };
    };

    # ─── Template Hosts (build but not actively deployed) ──────────────────
    wsl = {
      system = "x86_64-linux";
      hostname = "wsl";
      role = "workstation";
      user = "primary";
      features = [ "development" "wsl" ];
      description = "Windows Subsystem for Linux";
      isTemplate = true;
    };

    macbook-intel = {
      system = "x86_64-darwin";
      hostname = "macbook-intel";
      role = "workstation";
      user = "primary";
      features = [ "development" "gui" ];
      description = "MacBook (Intel)";
      isTemplate = true;
    };

    linux-arm = {
      system = "aarch64-linux";
      hostname = "linux-arm";
      role = "server";
      user = "primary";
      features = [ "development" ];
      description = "ARM Linux Server";
      isTemplate = true;
    };
  };

  # ── All Supported Systems ────────────────────────────────────────────────
  allSystems = [
    "aarch64-darwin"
    "x86_64-darwin"
    "x86_64-linux"
    "aarch64-linux"
  ];

  # ── Defaults ─────────────────────────────────────────────────────────────
  defaults = {
    shell = "zsh";
    editor = "nvim";
    terminal = "ghostty";
    stateVersion = "24.05";
  };

  # ── Feature Flags ────────────────────────────────────────────────────────
  features = {
    enableAITools = true;
    enableDevTools = true;
    enable1Password = true;
  };

  # ── Repository ───────────────────────────────────────────────────────────
  repo = {
    owner = "adampaterson";
    name = "dotfiles";
  };
}
