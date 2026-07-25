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
#
# The lookup itself is best-effort on purpose. This gate exists to save runner
# minutes, not to decide whether a PR is correct, so failing to read the API
# must never be what turns a PR red. GITHUB_TOKEN is rate limited per repository
# per hour and every gate job on every open PR draws on that one budget, so a
# batch of PRs exhausts it and each poll comes back 403. A failed lookup
# therefore backs off and retries, and a sustained run of them gives up waiting
# and lets the expensive job start.
#
# The interval grows toward MAX_INTERVAL for the same reason: a long wait is the
# congested case, which is exactly where polling hardest costs the most and buys
# the least.
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
  # `|| exit 1` inside the loop makes one failed SHA fail the whole pipeline;
  # without it only the last SHA's status counts and a partial answer would be
  # read as though the missing checks simply did not exist yet.
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
  back_off
done
