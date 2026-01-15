# dotfiles

Personal Nix configuration for macOS (nix-darwin), Linux (home-manager), and WSL2.

## Features

- **Cross-platform**: macOS (Apple Silicon + Intel), Linux (x86_64 + ARM), WSL2
- **Modular**: Each tool in its own module with enable/disable options
- **Role-based**: Workstation vs Server profiles
- **1Password integration**: Secrets managed via 1Password CLI
- **CI/CD**: GitHub Actions for linting, building, and deployment

## Directory Structure

```
dotfiles/
├── flake.nix              # Main flake configuration
├── meta.nix               # User/host metadata
├── lib/                   # Helper functions
├── hosts/                 # Host-specific configurations
│   ├── darwin/            # macOS hosts
│   └── linux/             # Linux/WSL hosts
├── modules/
│   ├── darwin/            # nix-darwin system modules
│   ├── home/              # home-manager modules
│   │   ├── platforms/     # Platform-specific (darwin, linux, wsl)
│   │   ├── shell/         # Shell configuration
│   │   └── tools/         # Tool modules (git, neovim, tmux, etc.)
│   └── roles/             # Role profiles (workstation, server)
├── overlays/              # Package overlays
├── pkgs/                  # Custom packages
├── secrets/               # 1Password references (no actual secrets)
└── .github/workflows/     # CI/CD pipelines
```

## Quick Start

### Prerequisites

1. Install Nix with flakes:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/adampaterson/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

### macOS

```bash
# Build and apply configuration
darwin-rebuild switch --flake .#macbook

# Or for Intel Mac
darwin-rebuild switch --flake .#macbook-intel
```

### Linux / Ubuntu

```bash
# Build and apply home-manager configuration
nix run home-manager -- switch --flake .#adampaterson@ubuntu-vps
```

### WSL2

```bash
# Build and apply WSL configuration
nix run home-manager -- switch --flake .#adampaterson@wsl
```

## Development

```bash
# Enter development shell with linting tools
nix develop

# Check flake
nix flake check

# Format all files
nix fmt

# Run linters
nix run nixpkgs#statix -- check .
nix run nixpkgs#deadnix -- -f .
```

## Adding a New Host

1. Add host definition to `meta.nix`:
   ```nix
   hosts.new-host = {
     system = "aarch64-darwin";  # or x86_64-linux, etc.
     hostname = "new-host";
     role = "workstation";       # or "server"
     user = "primary";
     features = [ "development" "gui" ];
   };
   ```

2. Create host config file:
   - Darwin: `hosts/darwin/new-host.nix`
   - Linux: `hosts/linux/new-host.nix`

3. Add to `flake.nix`:
   ```nix
   darwinConfigurations.new-host = lib.mkDarwinHost { hostname = "new-host"; };
   # or
   homeConfigurations."user@new-host" = lib.mkHomeConfiguration { hostname = "new-host"; };
   ```

## Adding a New Tool Module

1. Create module at `modules/home/tools/mytool/default.nix`:
   ```nix
   { config, lib, pkgs, ... }:
   let cfg = config.tools.mytool;
   in {
     options.tools.mytool.enable = lib.mkEnableOption "My tool";
     
     config = lib.mkIf cfg.enable {
       home.packages = [ pkgs.mytool ];
       xdg.configFile."mytool/config".source = ./config;
     };
   }
   ```

2. Add import to `modules/home/default.nix`:
   ```nix
   imports = [ ... ./tools/mytool ];
   ```

3. Enable in `modules/home/base.nix`:
   ```nix
   tools.mytool.enable = true;
   ```

## 1Password Setup

### GitHub Actions

1. Create a 1Password Service Account
2. Add `OP_SERVICE_ACCOUNT_TOKEN` to GitHub repository secrets
3. Store deployment secrets in 1Password vault `Nix`
4. If deploying over Tailscale, add `vps/tailscale-authkey` for CI

### Local Development

Use `op run` to inject secrets:
```bash
op run -- some-command-needing-secrets
```

## License

MIT
