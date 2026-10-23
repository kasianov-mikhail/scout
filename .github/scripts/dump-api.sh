#!/usr/bin/env bash
set -euo pipefail

dd="$1"
out="$2"
products="$dd/Build/Products/Debug-iphonesimulator"
sdk="$(xcrun --sdk iphonesimulator --show-sdk-path)"
manifest="$(swift package dump-package)"
ios="$(echo "$manifest" | jq -r '.platforms[] | select(.platformName == "ios") | .version')"

cc_flags=()
for modulemap in "$dd"/Build/Intermediates.noindex/GeneratedModuleMaps-iphonesimulator/*.modulemap; do
  [ -f "$modulemap" ] && cc_flags+=(-Xcc -fmodule-map-file="$modulemap")
done

module_flags=()
found=0
while IFS= read -r name; do
  [ -e "$products/$name.swiftmodule" ] || continue
  module_flags+=(-module "$name")
  found=$((found + 1))
done < <(echo "$manifest" | jq -r '.products[] | select(.type.library) | .targets[]' | sort -u)

if [ "$found" -eq 0 ]; then
  echo "No library product modules were built into $products" >&2
  exit 1
fi

dump="$(mktemp)"
xcrun swift-api-digester -dump-sdk "${module_flags[@]}" -o "$dump" \
  -avoid-location \
  -avoid-tool-args \
  -sdk "$sdk" \
  -target "arm64-apple-ios${ios}-simulator" \
  -I "$products" \
  "${cc_flags[@]}"

jq 'walk(if type == "array" then map(select(type != "object" or .isInternal != true)) else . end)' \
  "$dump" > "$out"

if ! jq -e '[.ABIRoot.children[]? | select(.declKind != "Import")] | length > 0' "$out" > /dev/null; then
  echo "::error::The API dump is empty, which means the dump produced nothing rather than that the package vends no API."
  exit 1
fi
