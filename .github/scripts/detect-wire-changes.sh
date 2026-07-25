#!/usr/bin/env bash
set -euo pipefail

: "${EVENT_NAME:?EVENT_NAME is required}"

if [ "$EVENT_NAME" != "pull_request" ]; then
  echo "backend=true" >> "$GITHUB_OUTPUT"
  exit 0
fi

: "${BASE_SHA:?BASE_SHA is required on a pull_request}"
changed="$(git diff --name-only "$BASE_SHA"...HEAD)"
if grep -qE '^(Sources/Connectors/Hosted/|Sources/Scout/Database/|Tests/Connectors/Hosted/|\.github/workflows/server\.yml$|\.github/scripts/)' <<<"$changed"; then
  echo "backend=true" >> "$GITHUB_OUTPUT"
else
  echo "backend=false" >> "$GITHUB_OUTPUT"
fi
