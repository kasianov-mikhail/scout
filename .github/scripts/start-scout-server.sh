#!/usr/bin/env bash
# Build and launch scout-server (checked out under ./scout-server), then wait
# for its health endpoint. Strict mode matters most for `swift build`: an
# unchecked compile failure used to fall through to a 60-second health poll and
# report "did not come up on port 8080" instead of the build error.
set -euo pipefail

cd scout-server
# Created before the build so the workflow's failure() log dump always has a
# file to read, even when the build is what failed.
: > server.log
swift build
nohup swift run --skip-build > server.log 2>&1 &
for _ in $(seq 1 60); do
  if curl -fs -o /dev/null http://127.0.0.1:8080/healthz; then
    exit 0
  fi
  sleep 1
done
echo "scout-server did not come up on port 8080"
exit 1
