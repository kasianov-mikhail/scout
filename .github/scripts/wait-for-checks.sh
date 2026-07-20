#!/usr/bin/env bash
# Hold an expensive job until the cheap PR checks it should never outrun have
# finished. A failing fast check — lint, the Core Data model-version rules, the
# wire-change probe — already red-flags the PR, so there is no point spending
# 20–30 minutes of macOS runner time on the long job behind it. This gate fails
# the instant any awaited check concludes in failure (which skips the dependent
# long job) and passes once they are all green (which lets it proceed).
#
# CHECKS holds check-run names, i.e. bare job names — "lint", "model-versions",
# "changes" — not the "Workflow / job" label the UI shows. A pull_request run
# attaches its check-runs to the head commit, but the merge commit is queried
# too so the lookup is robust to either association. SHAS and CHECKS are
# supplied by the workflow; TIMEOUT/INTERVAL fall back to sensible defaults.
set -euo pipefail

: "${SHAS:?SHAS is required}"
: "${CHECKS:?CHECKS is required}"
timeout="${TIMEOUT:-1200}"
interval="${INTERVAL:-15}"

read -ra shas <<< "$SHAS"
read -ra names <<< "$CHECKS"

deadline=$(( SECONDS + timeout ))
while :; do
  runs="$(
    for sha in "${shas[@]}"; do
      [ -n "$sha" ] || continue
      gh api --paginate \
        "repos/$GITHUB_REPOSITORY/commits/$sha/check-runs" \
        --jq '.check_runs[] | {name, status, conclusion, started_at}'
    done | jq -s '.'
  )"

  pending=()
  for name in "${names[@]}"; do
    # Reruns leave older entries behind, so pick the most recently started run.
    run="$(echo "$runs" | jq -c --arg n "$name" \
      '[.[] | select(.name == $n)] | sort_by(.started_at) | last')"
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
  sleep "$interval"
done
