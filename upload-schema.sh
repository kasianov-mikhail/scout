#!/bin/bash

# Uploads the CloudKit schema to the development environment.
# To deploy to production, use the CloudKit Console.
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

echo "Uploading schema to '$CONTAINER_ID' (development)..."
xcrun cktool import-schema \
    --team-id "$TEAM_ID" \
    --container-id "$CONTAINER_ID" \
    --environment "development" \
    --file "$SCHEMA_FILE"

echo "Schema uploaded successfully."
