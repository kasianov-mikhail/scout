#!/usr/bin/env bash
set -euo pipefail

: "${SHAS:?SHAS is required}"
: "${CHECKS:?CHECKS is required}"
timeout="${TIMEOUT:-10800}"
interval="${INTERVAL:-15}"
max_interval="${MAX_INTERVAL:-120}"
max_failures="${MAX_FAILURES:-10}"

read -ra shas <<< "$SHAS"
read -ra names <<< "$CHECKS"

back_off() {
  sleep "$interval"
  interval=$(( interval * 2 > max_interval ? max_interval : interval * 2 ))
}

deadline=$(( SECONDS + timeout ))
failures=0
while :; do
  if ! runs="$(
    for sha in "${shas[@]}"; do
      [ -n "$sha" ] || continue
      gh api --paginate \
        "repos/$GITHUB_REPOSITORY/commits/$sha/check-runs" \
        --jq '.check_runs[] | {name, status, conclusion, started_at}' || exit 1
    done | jq -s '.'
  )"; then
    failures=$(( failures + 1 ))
    if [ "$failures" -ge "$max_failures" ]; then
      echo "::warning::Could not read check-runs $failures times running (rate limit or API trouble). Starting the job anyway rather than blocking the PR on a lookup this gate only uses to save minutes."
      exit 0
    fi
    echo "Check-run lookup failed ($failures/$max_failures); retrying in ${interval}s."
    back_off
    continue
  fi
  failures=0

  pending=()
  for name in "${names[@]}"; do
    run="$(echo "$runs" | jq -c --arg n "$name" \
      '[.[] | select(.name == $n)] | sort_by(.started_at // "~") | last')"
    if [ -z "$run" ] || [ "$run" = "null" ]; then
      pending+=("$name(absent)")
      continue
    fi
    status="$(echo "$run" | jq -r '.status')"
    conclusion="$(echo "$run" | jq -r '.conclusion')"
    if [ "$status" != "completed" ]; then
      pending+=("$name($status)")
      continue
    fi
    case "$conclusion" in
      success | skipped | neutral) ;;
      *)
        echo "::error::Fast check '$name' concluded '$conclusion'; skipping the long job."
        exit 1
        ;;
    esac
  done

  if [ "${#pending[@]}" -eq 0 ]; then
    echo "All fast checks passed: ${names[*]}"
    exit 0
  fi

  if [ "$SECONDS" -ge "$deadline" ]; then
    echo "::error::Timed out after ${timeout}s still waiting on: ${pending[*]}"
    exit 1
  fi

  echo "Waiting on: ${pending[*]}"
  back_off
done
