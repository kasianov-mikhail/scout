#!/usr/bin/env bash
# The suite is skipped unless SCOUT_SERVER_URL reaches the test process, so a
# broken env hand-off (or an -only-testing identifier that matches nothing)
# would skip every test while xcodebuild still exits 0. Fail loudly when nothing
# actually ran rather than report a green that tested nothing.

summary="$(xcrun xcresulttool get test-results summary \
  --path TestResults.xcresult --compact)"
# `0 passed` is a real count (jq's // keeps it); only a missing field
# yields empty, in which case the schema changed — warn, don't block.
passed="$(echo "$summary" | jq '.passedTests // empty')"
if [ -z "$passed" ]; then
  echo "::warning::Could not read passedTests from the result bundle; skipping the ran-something check."
  echo "$summary" | head -c 2000
  exit 0
fi
echo "Contract tests passed: $passed"
if [ "$passed" -lt 1 ]; then
  echo "::error::No contract tests executed — the suite skipped (SCOUT_SERVER_URL likely never reached the test process) or matched nothing."
  exit 1
fi
