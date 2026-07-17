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

escaped="$(
  {
    grep -rlE 'HTTPDatabase|HTTPQueryCoding|HTTPRecordCoding' Sources
    grep -rlE '(struct|enum|final class|class) +(RecordReader|RecordChunk|RecordCursor)\b' Sources
  } | sort -u | grep -vE '^Sources/Scout/(Connectors/Hosted/|Database/)' || true
)"
if [ -n "$escaped" ]; then
  echo "::error::Wire-contract code lives outside the Server filter's watched paths; update the paths in this workflow to cover:"
  echo "$escaped"
  exit 1
fi
