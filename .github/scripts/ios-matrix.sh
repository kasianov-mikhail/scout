#!/usr/bin/env bash
set -euo pipefail

# Prints .github/matrix/ios.json as a one-line strategy.matrix value. Without arguments that is the
# full matrix; --ios and --configuration take comma-separated values and narrow it. Include entries
# whose iOS version is narrowed away are dropped too: an include entry naming a version absent from
# the matrix does not sit idle, it creates a job of its own.

source_file="$(dirname "$0")/../matrix/ios.json"
ios=""
configuration=""

while [ $# -gt 0 ]; do
  case "$1" in
    --ios)
      ios="${2:?--ios needs a comma-separated list of versions}"
      shift 2
      ;;
    --configuration)
      configuration="${2:?--configuration needs a comma-separated list of configurations}"
      shift 2
      ;;
    *)
      echo "::error::Unknown argument: $1"
      exit 1
      ;;
  esac
done

matrix="$(jq -c --arg ios "$ios" --arg configuration "$configuration" '
  def keep($spec):
    if $spec == "" then . else map(select(tostring as $value | $spec | split(",") | index($value))) end;

  .configuration |= keep($configuration)
  | .ios |= keep($ios)
  | .ios as $versions
  | .include |= map(select(.ios as $version | $versions | index($version)))
' "$source_file")"

for field in configuration ios; do
  if [ "$(jq --arg field "$field" '.[$field] | length' <<< "$matrix")" -eq 0 ]; then
    echo "::error::Narrowing left no $field values; check the arguments against $source_file."
    exit 1
  fi
done

echo "$matrix"
