#!/bin/bash

# Uploads the CloudKit schema to both development and production environments.
#
# Prerequisites:
#   Xcode command-line tools (cktool is included with Xcode)
#
# Usage:
#   ./upload-schema.sh <team-id> <container-id>
#
# Example:
#   ./upload-schema.sh ABCDE12345 iCloud.com.example.scout

set -euo pipefail

SCHEMA_FILE="$(dirname "$0")/Schema"
TEAM_ID="${1:?Usage: $0 <team-id> <container-id>}"
CONTAINER_ID="${2:?Usage: $0 <team-id> <container-id>}"

if ! xcrun --find cktool &> /dev/null; then
    echo "Error: cktool not found. Make sure Xcode command-line tools are installed."
    exit 1
fi

if [ ! -f "$SCHEMA_FILE" ]; then
    echo "Error: Schema file not found at $SCHEMA_FILE"
    exit 1
fi

for ENV in development production; do
    echo "Uploading schema to '$CONTAINER_ID' ($ENV)..."
    xcrun cktool import-schema \
        --team-id "$TEAM_ID" \
        --container-id "$CONTAINER_ID" \
        --environment "$ENV" \
        --file "$SCHEMA_FILE"
    echo "$ENV: done."
done

echo "Schema uploaded successfully."
