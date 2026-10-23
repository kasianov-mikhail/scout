#!/usr/bin/env bash
set -euo pipefail

derived="${1:?a derived data path is required}"

xcodebuild \
  -scheme Scout-Package \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$derived" \
  -clonedSourcePackagesDirPath /tmp/spm \
  -skipMacroValidation \
  -quiet \
  build
