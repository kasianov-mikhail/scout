#!/usr/bin/env bash
set -euo pipefail

baseline="$1"
current="$2"
report="$(mktemp)"

xcrun swift-api-digester -diagnose-sdk \
  -input-paths "$baseline" \
  -input-paths "$current" \
  -o "$report"

grep -vE '^(/\*.*\*/)?$' "$report" || true
