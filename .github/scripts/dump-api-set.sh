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
  -sdk "$sdk" \
  -target "arm64-apple-ios${ios}-simulator" \
  -I "$products" \
  "${cc_flags[@]}"

jq -r '
  def emit($prefix):
    if .isInternal == true then empty
    elif (.declKind != null and .declKind != "Import" and .declKind != "Accessor")
    then ($prefix + (if $prefix == "" then "" else "." end) + .printedName) as $qualified
         | "\(.declKind) \($qualified)", (.children[]? | emit($qualified))
    else (.children[]? | emit($prefix)) end;
  .ABIRoot | emit("")
' "$dump" | sort -u > "$out"
