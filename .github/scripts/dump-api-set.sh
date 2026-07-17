#!/usr/bin/env bash
# Dump the package's public + package API as a module-agnostic set, one
# "<declKind> <qualified printed name>" per line.
#
# The split moved most declarations out of the single `Scout` module into
# ScoutCore and the adapter modules, re-exporting them through the umbrella.
# swift-api-digester keys every symbol by its defining module and does not
# follow `@_exported import`, so a per-module diff reports every moved symbol as
# removed even though `import Scout` consumers still compile. Flattening every
# package module into one module-agnostic set makes a move a no-op (the symbol
# still exists somewhere) while a genuine deletion still drops out of the set.
#
# Args: <derived-data-path> <output-set-file>
set -euo pipefail

dd="$1"
out="$2"
products="$dd/Build/Products/Debug-iphonesimulator"
sdk="$(xcrun --sdk iphonesimulator --show-sdk-path)"
ios="$(swift package dump-package | jq -r '.platforms[] | select(.platformName == "ios") | .version')"

# swift-api-digester loads modules through the Clang importer, which doesn't
# discover a Swift package's C-target module maps on its own — point it at the
# ones xcodebuild already generated for this build.
cc_flags=()
for modulemap in "$dd"/Build/Intermediates.noindex/GeneratedModuleMaps-iphonesimulator/*.modulemap; do
  [ -f "$modulemap" ] && cc_flags+=(-Xcc -fmodule-map-file="$modulemap")
done

# The package's own Swift library modules are the built Scout* modules minus the
# external scout-db products; ScoutHang is a C target with no .swiftmodule.
module_flags=()
for swiftmodule in "$products"/Scout*.swiftmodule; do
  name="$(basename "$swiftmodule" .swiftmodule)"
  case "$name" in
    ScoutDB | ScoutDBTesting) continue ;;
  esac
  module_flags+=(-module "$name")
done

dump="$(mktemp)"
xcrun swift-api-digester -dump-sdk "${module_flags[@]}" -o "$dump" \
  -sdk "$sdk" \
  -target "arm64-apple-ios${ios}-simulator" \
  -I "$products" \
  "${cc_flags[@]}"

# Qualify each declaration with its ancestor names so members don't collide
# across types, and drop the module identity so a cross-module move is not a
# change. Imports and synthesized accessors are noise.
jq -r '
  def emit($prefix):
    if (.declKind != null and .declKind != "Import" and .declKind != "Accessor")
    then ($prefix + (if $prefix == "" then "" else "." end) + .printedName) as $qualified
         | "\(.declKind) \($qualified)", (.children[]? | emit($qualified))
    else (.children[]? | emit($prefix)) end;
  .ABIRoot | emit("")
' "$dump" | sort -u > "$out"
