#!/usr/bin/env bash
set -euo pipefail

: "${SHAS:?SHAS is required}"
: "${CHECKS:?CHECKS is required}"
timeout="${TIMEOUT:-10800}"
absent_timeout="${ABSENT_TIMEOUT:-900}"
cancelled_timeout="${CANCELLED_TIMEOUT:-900}"
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
absent_deadline=$(( SECONDS + absent_timeout ))
cancelled_deadline=0
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
  cancelled=()
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
      cancelled | stale)
        cancelled+=("$name")
        pending+=("$name(cancelled)")
        ;;
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

  if [ "${#cancelled[@]}" -eq 0 ]; then
    cancelled_deadline=0
  elif [ "$cancelled_deadline" -eq 0 ]; then
    cancelled_deadline=$(( SECONDS + cancelled_timeout ))
    echo "::warning::Cancelled, not failed: ${cancelled[*]}. A cancellation carries no verdict, so this gate waits ${cancelled_timeout}s for a re-run to post a fresh check instead of turning the pull request red."
  elif [ "$SECONDS" -ge "$cancelled_deadline" ]; then
    echo "::error::Still cancelled after ${cancelled_timeout}s: ${cancelled[*]}. Nothing re-ran them, so no verdict can arrive — re-run the cancelled workflow. This is the runner, not the code under test."
    exit 1
  fi

  if [ "$SECONDS" -ge "$absent_deadline" ]; then
    absent="$(printf '%s\n' "${pending[@]}" | grep -F '(absent)' || true)"
    if [ -n "$absent" ]; then
      echo "::error::No check run appeared within ${absent_timeout}s for: $(echo $absent) — if the job was renamed, update the CHECKS list in this workflow."
      exit 1
    fi
  fi

  if [ "$SECONDS" -ge "$deadline" ]; then
    echo "::error::Timed out after ${timeout}s still waiting on: ${pending[*]}"
    exit 1
  fi

  echo "Waiting on: ${pending[*]}"
  back_off
done
