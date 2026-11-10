#!/usr/bin/env bash
set -euo pipefail

: "${EVENT_NAME:?EVENT_NAME is required}"
: "${PATTERN:?PATTERN is required}"
: "${OUTPUT:?OUTPUT is required}"

emit() {
  echo "$OUTPUT=$1"
  echo "$OUTPUT=$1" >> "$GITHUB_OUTPUT"
}

case "$EVENT_NAME" in
  pull_request)
    base="${BASE_SHA:?BASE_SHA is required on a pull_request}"
    head="${HEAD_SHA:?HEAD_SHA is required on a pull_request}"
    ;;
  push)
    base="${BEFORE_SHA:-}"
    head=HEAD
    ;;
  *)
    emit true
    exit 0
    ;;
esac

if [ -z "$base" ] || [ "$base" = "0000000000000000000000000000000000000000" ] \
  || ! git cat-file -e "$base^{commit}" 2>/dev/null \
  || ! git cat-file -e "$head^{commit}" 2>/dev/null; then
  echo "No usable revisions ($base, $head); treating the change as a match."
  emit true
  exit 0
fi

changed="$(git diff --name-only "$base"..."$head")"
echo "$changed"

if grep -qE "$PATTERN" <<<"$changed"; then
  emit true
else
  emit false
fi
