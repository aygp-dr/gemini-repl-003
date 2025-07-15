#!/bin/sh
# Create a GitHub issue using the CLI

if [ $# -lt 2 ]; then
    echo "Usage: $0 <title> <body> [labels]"
    exit 1
fi

TITLE="$1"
BODY="$2"
LABELS="${3:-bug}"

gh issue create \
    --title "$TITLE" \
    --body "$BODY" \
    --label "$LABELS"
