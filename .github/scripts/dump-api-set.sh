#!/usr/bin/env bash
# Dump the package's public API as a module-agnostic set, one
# "<declKind> <qualified printed name>" per line.
#
# Most declarations live in `Scout` (the package's base module) and the
# adapter modules (`NativeConnector`, `HostedConnector`, `ScoutUI`, `Cache`).
# swift-api-digester keys every symbol by its defining module, so moving a
# symbol between these modules reports as a removal even though downstream
# consumers still compile. Flattening every package module into one
# module-agnostic set makes a move a no-op (the symbol still exists somewhere)
# while a genuine deletion still drops out of the set.
#
# Args: <derived-data-path> <output-set-file>
set -euo pipefail

dd="$1"
out="$2"
products="$dd/Build/Products/Debug-iphonesimulator"
sdk="$(xcrun --sdk iphonesimulator --show-sdk-path)"
manifest="$(swift package dump-package)"
ios="$(echo "$manifest" | jq -r '.platforms[] | select(.platformName == "ios") | .version')"

# swift-api-digester loads modules through the Clang importer, which doesn't
# discover a Swift package's C-target module maps on its own — point it at the
# ones xcodebuild already generated for this build.
cc_flags=()
for modulemap in "$dd"/Build/Intermediates.noindex/GeneratedModuleMaps-iphonesimulator/*.modulemap; do
  [ -f "$modulemap" ] && cc_flags+=(-Xcc -fmodule-map-file="$modulemap")
done

# The modules to dump are the targets the package vends as library products,
# read from the manifest rather than spelled out here: a hardcoded list turns
# vacuous the moment a target is renamed, which is how the module formerly
# called Cache silently dropped out of the comparison. CScoutHang is a C target
# with no .swiftmodule and vends no library product, and the external scout-db
# products are not in this manifest's products at all.
module_flags=()
found=0
while IFS= read -r name; do
  # A .swiftmodule can be either a file or a multi-arch directory, so test for
  # either kind of entry; a product whose scheme the workflow did not build has
  # none at all.
  [ -e "$products/$name.swiftmodule" ] || continue
  module_flags+=(-module "$name")
  found=$((found + 1))
done < <(echo "$manifest" | jq -r '.products[] | select(.type.library) | .targets[]' | sort -u)

# An empty dump would compare as "every symbol removed" on the current side and
# as "nothing to compare" on the baseline side, so stop instead of guessing.
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

# Qualify each declaration with its ancestor names so members don't collide
# across types, and drop the module identity so a cross-module move is not a
# change. Imports and synthesized accessors are noise.
#
# The dump also carries `package` declarations, which the digester marks
# `isInternal`. They are unreachable outside this package, so removing one
# cannot break an integration — skip those subtrees and compare public API
# only.
jq -r '
  def emit($prefix):
    if .isInternal == true then empty
    elif (.declKind != null and .declKind != "Import" and .declKind != "Accessor")
    then ($prefix + (if $prefix == "" then "" else "." end) + .printedName) as $qualified
         | "\(.declKind) \($qualified)", (.children[]? | emit($qualified))
    else (.children[]? | emit($prefix)) end;
  .ABIRoot | emit("")
' "$dump" | sort -u > "$out"
