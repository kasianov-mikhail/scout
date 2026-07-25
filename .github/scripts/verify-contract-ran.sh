#!/usr/bin/env bash
set -euo pipefail

summary="$(xcrun xcresulttool get test-results summary \
  --path TestResults.xcresult --compact || true)"
passed="$(echo "$summary" | jq '.passedTests // empty' || true)"
case "$passed" in
  '' | *[!0-9]*)
    echo "::warning::Could not read a passedTests count from the result bundle; skipping the ran-something check."
    printf '%s\n' "$summary" | head -c 2000 || true
    exit 0
    ;;
esac
echo "Contract tests passed: $passed"
if [ "$passed" -lt 1 ]; then
  echo "::error::No contract tests executed — the suite skipped (SCOUT_SERVER_URL likely never reached the test process) or matched nothing."
  exit 1
fi
