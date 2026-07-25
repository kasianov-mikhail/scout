#!/usr/bin/env bash
# Tripwire against filter drift. The Server workflow's path filter duplicates
# the knowledge of where the wire code lives, so a future move out of the
# watched directories would silently stop triggering `contract` while the gate
# stays green. Symbol names outlive folder layout, so assert the wire code still
# sits under a watched root and fail loudly (red PR) when it escapes — that is
# the signal to widen the filter. The HTTP* coders are wire-specific, so any
# mention pins them down; the Record pagination types are shared infra used all
# over the app, so only their definition sites matter (their use sites
# legitimately live outside the watched roots).
#
# Every pattern is asserted to match something, one at a time. Checking them as
# a group hides rot behind whichever pattern still resolves, and because the
# guard keys on symbol names, a rename that empties one pattern retires that
# part of the tripwire without anyone noticing — the failure it exists to catch.
set -euo pipefail

matched=""
missing=""

# Args: <label> <extended regex>
check() {
  local label="$1" pattern="$2" hits status
  set +e
  hits="$(grep -rlE "$pattern" Sources)"
  status=$?
  set -e
  # grep exits 1 for "no match" and 2 or more for a real error; only the former
  # means the symbol is gone, so anything else has to stop the job outright.
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
