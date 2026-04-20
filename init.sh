#!/bin/sh
set -eu

DOTFILES_REPO="${DOTFILES_REPO:-adam-paterson/dotfiles}"
DOTFILES_REF="${DOTFILES_REF:-}"
DOTFILES_SSH="${DOTFILES_SSH:-}"

usage() {
	cat >&2 <<'EOF'
Usage: init.sh [options] [-- <chezmoi init flags>]

Options:
  --repo <repo>     GitHub repo (default: adam-paterson/dotfiles)
  --ref <ref>       Branch or tag to checkout
  --ssh             Use SSH for git clone
  -h, --help        Show this help

Examples:
  ./init.sh
  ./init.sh --ssh
  ./init.sh --repo adam-paterson/dotfiles --ref main --ssh
  curl -fsLS https://raw.githubusercontent.com/adam-paterson/dotfiles/main/init.sh | sh -s -- --ssh
EOF
}

repo="$DOTFILES_REPO"
ref="$DOTFILES_REF"
ssh="$DOTFILES_SSH"

while [ $# -gt 0 ]; do
	case "$1" in
	-h | --help)
		usage
		exit 0
		;;
	--repo)
		shift
		repo="${1:?--repo requires a value}"
		;;
	--ref | --branch)
		shift
		ref="${1:?--ref requires a value}"
		;;
	--ssh) ssh=1 ;;
	--)
		shift
		break
		;;
	-*)
		echo "error: unknown option: $1" >&2
		usage
		exit 2
		;;
	*)
		echo "error: unexpected argument: $1" >&2
		exit 2
		;;
	esac
	shift
done

# Install chezmoi using the official installer (downloads standalone binary,
# handles NixOS musl, architecture detection, retries, checksums)
if ! command -v chezmoi >/dev/null 2>&1; then
	echo ":: Installing chezmoi..."
	bindir="$HOME/bin"
	mkdir -p "$bindir"
	if command -v curl >/dev/null 2>&1; then
		sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$bindir"
	elif command -v wget >/dev/null 2>&1; then
		sh -c "$(wget -qO- https://get.chezmoi.io)" -- -b "$bindir"
	else
		echo "error: curl or wget required" >&2
		exit 1
	fi
else
	chezmoi=chezmoi
fi

# Ensure PATH includes common chezmoi locations
for dir in "$HOME/bin" "$HOME/.local/bin"; do
	if [ -d "$dir" ]; then
		PATH="$dir:$PATH"
	fi
done
export PATH

# Build the chezmoi init command
set --
if [ -n "$ssh" ]; then set -- "$@" --ssh; fi
if [ -n "$ref" ]; then set -- "$@" --branch "$ref"; fi
set -- "$@" "$repo"

echo ":: Bootstrapping dotfiles with chezmoi"
exec chezmoi init --apply "$@"
