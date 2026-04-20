#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

require_cmd() {
    command -v "$1" >/dev/null 2>&1
}

for c in bash python3; do
    require_cmd "$c" || {
        echo "SKIP: missing dependency: $c" >&2
        exit 0
    }
done

python3 - "$ROOT/.chezmoiscripts/run_onchange_after_04_install-mise-tools.sh.tmpl" <<'PY'
from pathlib import Path
import sys

script = Path(sys.argv[1]).read_text(encoding="utf-8")

needles = {
    "python_guard": "if ! command -v python &>/dev/null; then",
    "python_install": '"$mise_cmd" install --yes python',
    "python_reactivate": 'eval "$("$mise_cmd" activate bash)"',
    "npm_guard": "if ! command -v npm &>/dev/null; then",
    "node_install": '"$mise_cmd" install --yes node',
}

positions = {}
for name, needle in needles.items():
    pos = script.find(needle)
    if pos == -1:
        raise SystemExit(f"missing expected snippet: {needle}")
    positions[name] = pos

if not positions["python_guard"] < positions["python_install"] < positions["npm_guard"] < positions["node_install"]:
    raise SystemExit("python bootstrap does not occur before node bootstrap")
PY

echo "test_mise_bootstrap_order: OK"
