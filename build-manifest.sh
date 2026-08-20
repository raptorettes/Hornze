#!/usr/bin/env bash
set -euo pipefail
EXPORT_DIR="${1:-./exports}"
python3 "$(dirname "$0")/ci/generate-manifest.py" --export-dir "$EXPORT_DIR"
