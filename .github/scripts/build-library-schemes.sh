#!/usr/bin/env bash
set -euo pipefail

derived="${1:?a derived data path is required}"

schemes="$(swift package dump-package | jq -r '.products[] | select(.type.library) | .name')"
if [ -z "$schemes" ]; then
  echo "::error::No library products found in the manifest."
  exit 1
fi

for scheme in $schemes; do
  xcodebuild \
    -scheme "$scheme" \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$derived" \
    -clonedSourcePackagesDirPath /tmp/spm \
    -skipMacroValidation \
    -quiet \
    build
done
