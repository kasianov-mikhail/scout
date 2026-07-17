#!/usr/bin/env bash
# Decide whether the wire surface changed and write the `backend` output.
# Non-PR events always exercise the contract; PRs diff against the base SHA.
# EVENT_NAME and BASE_SHA are supplied by the workflow from the GitHub context.

if [ "$EVENT_NAME" != "pull_request" ]; then
  echo "backend=true" >> "$GITHUB_OUTPUT"
  exit 0
fi
if git diff --name-only "$BASE_SHA"...HEAD \
  | grep -qE '^(Sources/ScoutHosted/|Sources/ScoutCore/Database/|Tests/ScoutHostedTests/|\.github/workflows/server\.yml$)'; then
  echo "backend=true" >> "$GITHUB_OUTPUT"
else
  echo "backend=false" >> "$GITHUB_OUTPUT"
fi
