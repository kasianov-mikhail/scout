#!/usr/bin/env bash
set -euo pipefail

: "${EVENT_NAME:?EVENT_NAME is required}"

emit() {
  echo "code=$1"
  echo "code=$1" >> "$GITHUB_OUTPUT"
}

case "$EVENT_NAME" in
  pull_request)
    base="${BASE_SHA:?BASE_SHA is required on a pull_request}"
    ;;
  push)
    base="${BEFORE_SHA:-}"
    ;;
  *)
    emit true
    exit 0
    ;;
esac

if [ -z "$base" ] || [ "$base" = "0000000000000000000000000000000000000000" ] \
  || ! git cat-file -e "$base^{commit}" 2>/dev/null; then
  echo "No usable base revision ($base); treating the change as code."
  emit true
  exit 0
fi

changed="$(git diff --name-only "$base"...HEAD)"
echo "$changed"

if grep -qE '^(Sources/|Tests/|Package\.swift$|\.swift-format$|\.github/)' <<<"$changed"; then
  emit true
else
  emit false
fi
