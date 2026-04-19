#!/usr/bin/env bash

if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
	source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
elif [[ -f "/nix/etc/profile.d/nix-daemon.sh" ]]; then
	source "/nix/etc/profile.d/nix-daemon.sh"
fi

# Ensure aqua and mise bin dirs are on PATH for scripts
AQUA_BIN_DIR="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin"
MISE_BIN_DIR="${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims"

if [[ -d "$AQUA_BIN_DIR" ]] && [[ ":$PATH:" != *":$AQUA_BIN_DIR:"* ]]; then
	export PATH="$AQUA_BIN_DIR:$PATH"
fi

if [[ -d "$MISE_BIN_DIR" ]] && [[ ":$PATH:" != *":$MISE_BIN_DIR:"* ]]; then
	export PATH="$MISE_BIN_DIR:$PATH"
fi

if [[ -d "$HOME/.local/bin" ]] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
	export PATH="$HOME/.local/bin:$PATH"
fi
