#!/usr/bin/env bash
set -euo pipefail

status=0
for entry in "$@"; do
  IFS='|' read -r label result allowed <<< "$entry"
  : "${label:?a result entry needs a label}"
  : "${result:?$label has no result; check the needs.<job>.result reference}"
  allowed="${allowed:-success}"

  if [[ ",$allowed," == *",$result,"* ]]; then
    continue
  fi

  status=1
  if [ "$result" = cancelled ] || [ "$result" = abandoned ]; then
    echo "::error::$label was $result, so it never reached a verdict. That says the run was superseded, or a job waited for a runner that never arrived — re-run the failed jobs rather than reading this as a problem with the code."
  else
    echo "::error::$label did not pass ($result)."
  fi
done

exit "$status"
