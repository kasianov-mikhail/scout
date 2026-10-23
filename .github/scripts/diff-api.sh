#!/usr/bin/env bash
set -euo pipefail

baseline="$1"
current="$2"
api="$(mktemp)"
abi="$(mktemp)"

xcrun swift-api-digester -diagnose-sdk \
  -input-paths "$baseline" \
  -input-paths "$current" \
  -o "$api"

xcrun swift-api-digester -diagnose-sdk -abi \
  -input-paths "$baseline" \
  -input-paths "$current" \
  -o "$abi"

grep -vE '^(/\*.*\*/)?$' "$api" || true

# API mode does not see async; ABI mode shows a function turning async only in its mangled name.
awk -F"'" '/ has mangled name changing from / {
  old = $2
  new = $4
  if (gsub(/ async/, "", new) > gsub(/ async/, "", old)) print
}' "$abi" > "$abi.async"
while IFS= read -r line; do
  decl="${line%% has mangled name changing *} "
  awk -v decl="$decl" 'index($0, decl) == 1 { found = 1 } END { exit !found }' "$api" \
    || echo "${decl}is now async"
done < "$abi.async"
