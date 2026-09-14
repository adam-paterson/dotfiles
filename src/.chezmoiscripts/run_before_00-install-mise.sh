#!/bin/sh
set -eu

export PATH="$HOME/.local/bin:$PATH"
if command -v mise >/dev/null 2>&1; then
    exit 0
fi

# Download completely before executing; a failed download must stop apply.
installer=$(mktemp)
trap 'rm -f "$installer"' EXIT HUP INT TERM
curl --fail --silent --show-error --location https://mise.run --output "$installer"
MISE_INSTALL_PATH="$HOME/.local/bin/mise" sh "$installer"
"$HOME/.local/bin/mise" --version
