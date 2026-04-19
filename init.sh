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

CHEZMOI_VERSION="2.69.0"

# Install or upgrade chezmoi
install_chezmoi() {
	echo ":: Installing chezmoi v${CHEZMOI_VERSION}..."

	GOOS=$(uname -s | tr '[:upper:]' '[:lower:]')
	GOARCH=$(uname -m)
	case "$GOARCH" in
	x86_64 | amd64) GOARCH="amd64" ;;
	aarch64 | arm64) GOARCH="arm64" ;;
	esac

	# On NixOS, use the musl build (statically linked, no glibc dependency)
	GOOS_EXTRA=""
	if [ -f /etc/NIXOS ]; then
		GOOS_EXTRA="-musl"
	fi

	TARBALL="chezmoi_${CHEZMOI_VERSION}_${GOOS}${GOOS_EXTRA}_${GOARCH}.tar.gz"
	TARBALL_URL="https://github.com/twpayne/chezmoi/releases/download/v${CHEZMOI_VERSION}/${TARBALL}"

	TMPDIR=$(mktemp -d)
	trap 'rm -rf "$TMPDIR"' EXIT

	echo "    Downloading $TARBALL_URL..."
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL "$TARBALL_URL" -o "$TMPDIR/$TARBALL"
	elif command -v wget >/dev/null 2>&1; then
		wget -qO "$TMPDIR/$TARBALL" "$TARBALL_URL"
	else
		echo "error: curl or wget required" >&2
		exit 1
	fi

	tar -xzf "$TMPDIR/$TARBALL" -C "$TMPDIR"

	BINDIR="$HOME/.local/bin"
	mkdir -p "$BINDIR"
	mv "$TMPDIR/chezmoi" "$BINDIR/chezmoi"
	chmod +x "$BINDIR/chezmoi"

	echo "    Installed: $($BINDIR/chezmoi --version 2>/dev/null || echo 'ok')"
}

NEEDED_MAJOR=2
NEEDED_MINOR=69

if ! command -v chezmoi >/dev/null 2>&1; then
	install_chezmoi
else
	CURRENT_VERSION=$(chezmoi --version 2>/dev/null | head -1 | sed 's/.*version //' | sed 's/[^0-9.].*//')
	CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
	CURRENT_MINOR=$(echo "$CURRENT_VERSION" | cut -d. -f2)

	NEEDS_UPGRADE=0
	if [ -z "$CURRENT_MAJOR" ] || [ -z "$CURRENT_MINOR" ]; then
		NEEDS_UPGRADE=1
	elif [ "$CURRENT_MAJOR" -lt "$NEEDED_MAJOR" ] 2>/dev/null; then
		NEEDS_UPGRADE=1
	elif [ "$CURRENT_MAJOR" -eq "$NEEDED_MAJOR" ] && [ "$CURRENT_MINOR" -lt "$NEEDED_MINOR" ] 2>/dev/null; then
		NEEDS_UPGRADE=1
	fi

	if [ "$NEEDS_UPGRADE" -eq 1 ]; then
		echo ":: Installed chezmoi is too old ($CURRENT_VERSION, need >= $NEEDED_MAJOR.$NEEDED_MINOR.0)"
		install_chezmoi
	fi
fi

# Ensure PATH includes common chezmoi locations
for dir in "$HOME/.local/bin" "$HOME/bin"; do
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
