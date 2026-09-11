#!/bin/sh
set -eu

export PATH="$HOME/.local/bin:$PATH"
# Use the applied global configuration, not the caller's project configuration.
cd "$HOME"
# Run every apply: mise skips installed tools and retries incomplete installs.
mise install
