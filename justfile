# Nix Configuration Task Runner
# Run `just` to see all available commands

# Default: list all commands
default:
    @just --list

# ─────────────────────────────────────────────────────────────
# Formatting & Linting
# ─────────────────────────────────────────────────────────────

# Format all Nix files
fmt:
    nix fmt

# Check formatting without modifying
fmt-check:
    nix fmt -- --check .

# Run statix linter
lint:
    nix run nixpkgs#statix -- check .

# Auto-fix statix issues
lint-fix:
    nix run nixpkgs#statix -- fix .

# Find dead/unused code
deadnix:
    nix run nixpkgs#deadnix -- .

# Auto-remove dead code
deadnix-fix:
    nix run nixpkgs#deadnix -- --edit .

# Run all checks (mirrors CI)
check: fmt-check lint deadnix
    nix flake check --no-build

# Fix all auto-fixable issues
fix: fmt lint-fix deadnix-fix

# ─────────────────────────────────────────────────────────────
# Building
# ─────────────────────────────────────────────────────────────

# Build macbook configuration
build-macbook:
    nix build .#darwinConfigurations.macbook.system --no-link --print-build-logs

# Build ubuntu-vps configuration
build-vps:
    nix build '.#homeConfigurations."adampaterson@ubuntu-vps".activationPackage' --no-link --print-build-logs

# ─────────────────────────────────────────────────────────────
# Switching / Applying
# ─────────────────────────────────────────────────────────────

# Apply macbook configuration
switch:
    darwin-rebuild switch --flake .#macbook

# Apply macbook configuration (trace errors)
switch-debug:
    darwin-rebuild switch --flake .#macbook --show-trace

# ─────────────────────────────────────────────────────────────
# Maintenance
# ─────────────────────────────────────────────────────────────

# Update all flake inputs
update:
    nix flake update

# Update specific input (e.g., just update nixpkgs)
update-input input:
    nix flake lock --update-input {{input}}

# Garbage collect old generations
gc:
    nix-collect-garbage -d

# Show flake info
info:
    nix flake show
    nix flake metadata

# ─────────────────────────────────────────────────────────────
# Development
# ─────────────────────────────────────────────────────────────

# Enter development shell
dev:
    nix develop

# Install git hooks (run once after clone)
hooks:
    nix run nixpkgs#lefthook -- install
