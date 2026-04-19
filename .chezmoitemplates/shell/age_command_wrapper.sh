#!/usr/bin/env bash
set -euo pipefail

if ! command -v age &>/dev/null; then
	echo "age is required for decryption but not found"
	exit 1
fi

CHEZMOI_IDENTITY="${1:-$HOME/.ssh/main}"

if [[ ! -f "$CHEZMOI_IDENTITY" ]]; then
	echo "Error: age identity file not found at $CHEZMOI_IDENTITY"
	echo "Run the encryption key restore script first, or set up your SSH keys."
	exit 1
fi

age_wrapper() {
	age -i "$CHEZMOI_IDENTITY" "$@"
}

age_wrapper "$@"
