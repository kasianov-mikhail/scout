#!/usr/bin/env bash
set -euo pipefail

rev="${1:?the revision whose API the dump describes is required}"
toolchain="${2:?the toolchain id is required}"

sources="$(git ls-tree "$rev" | grep -E $'\t(Sources|Package(@swift-[0-9.]+)?\\.swift)$' | git hash-object --stdin)"
tools="$(git ls-tree HEAD .github/scripts/build-library-schemes.sh .github/scripts/dump-api.sh | git hash-object --stdin)"
echo "api-baseline-$toolchain-$tools-$sources"
