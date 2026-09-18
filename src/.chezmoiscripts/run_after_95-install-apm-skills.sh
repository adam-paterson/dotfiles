#!/bin/sh
set -eu

export PATH="$HOME/.local/bin:$PATH"
cd "$HOME"

# Allow applies before the existing skills have been migrated to APM.
if [ ! -f "$HOME/.apm/apm.yml" ]; then
    printf '%s\n' 'Skipping APM skills: ~/.apm/apm.yml is not configured.'
    exit 0
fi

mise exec -- apm install --global --frozen --only apm --no-trust-bin
