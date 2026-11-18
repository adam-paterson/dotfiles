#!/bin/sh
set -eu

export PATH="$HOME/.local/bin:$PATH"
# Use the applied global configuration, not the caller's project configuration.
cd "$HOME"
# Run every apply: mise skips installed tools and retries incomplete installs.
# Anonymous raw.githubusercontent access is rate-limited per IP and can 404
# under load (observed on Seraph fetching mise-declared skills); a token
# keeps those downloads on the authenticated path.
if command -v gh >/dev/null 2>&1; then
    GITHUB_TOKEN="$(gh auth token)"
    export GITHUB_TOKEN
fi
mise install
