#!/usr/bin/env bash
# Decide whether the wire surface changed and write the `backend` output.
# Non-PR events always exercise the contract; PRs diff against the base SHA.
# EVENT_NAME and BASE_SHA are supplied by the workflow from the GitHub context.
#
# The diff is captured into a variable before it is matched so that a git
# failure aborts the job. Piping git straight into grep hides it: a diff that
# cannot be computed prints nothing, grep reads that as "no wire files touched",
# the contract job skips, and contract-gate reports green on a PR nothing
# checked.
#
# The match then reads that variable through a here-string rather than a pipe.
# `grep -q` exits at the first match, so with pipefail on, a writer feeding it
# more than a pipe buffer's worth of paths dies of SIGPIPE and the pipeline
# reports 141 even though grep matched — inverting the result into the same
# silent backend=false this file exists to avoid.
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
