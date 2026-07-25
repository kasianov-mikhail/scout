#!/usr/bin/env bash
set -euo pipefail

matched=""
missing=""

check() {
  local label="$1" pattern="$2" hits status
  set +e
  hits="$(grep -rlE "$pattern" Sources)"
  status=$?
  set -e
  if [ "$status" -gt 1 ]; then
    echo "::error::grep exited $status while searching for $label."
    exit 1
  fi
  if [ -z "$hits" ]; then
    missing="$missing $label"
    return
  fi
  matched="$matched$hits"$'\n'
}

check HTTPDatabase 'HTTPDatabase'
check HTTPQuery 'HTTPQuery'
check HTTPRecord 'HTTPRecord'
check RecordChunk '(struct|enum|final class|class) +RecordChunk\b'
check RecordCursor '(struct|enum|final class|class) +RecordCursor\b'

if [ -n "$missing" ]; then
  echo "::error::These guard patterns match nothing under Sources, so the guard can no longer tell whether the wire code moved:$missing"
  echo "Rename them here to the current symbol names, and check the Server workflow's paths still cover where those symbols now live."
  exit 1
fi

escaped="$(printf '%s' "$matched" | sort -u | grep -vE '^Sources/(Connectors/Hosted/|Scout/Database/)' || true)"
if [ -n "$escaped" ]; then
  echo "::error::Wire-contract code lives outside the Server filter's watched paths; update the paths in this workflow to cover:"
  echo "$escaped"
  exit 1
fi
