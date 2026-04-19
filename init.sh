#!/usr/bin/env bash
set -euo pipefail

echo ":: Bootstrapping dotfiles with chezmoi"

if ! command -v git &>/dev/null; then
	echo "Error: git is required but not found"
	exit 1
fi

if ! command -v chezmoi &>/dev/null; then
	echo "Installing chezmoi..."
	if [[ "$(uname -s)" == "Darwin" ]]; then
		if command -v brew &>/dev/null; then
			brew install chezmoi
		else
			sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin"
		fi
	elif [[ "$(uname -s)" == "Linux" ]]; then
		if command -v nix &>/dev/null; then
			nix profile install nixpkgs#chezmoi
		else
			sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin"
		fi
	else
		sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin"
	fi
fi

if [[ -d "${HOME}/.local/share/chezmoi" ]]; then
	echo "Existing chezmoi source directory found"
	echo "Initializing and applying..."
	chezmoi init --apply
else
	echo "No existing chezmoi source directory"
	echo "Cloning and applying..."
	chezmoi init --apply --ssh
fi

echo ""
echo ":: Bootstrap complete"
echo "   Run 'chezmoi doctor' to verify your setup"
