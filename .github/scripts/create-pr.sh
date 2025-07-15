#!/usr/bin/env sh
# Create a pull request using the CLI

if [ $# -lt 2 ]; then
    echo "Usage: $0 <title> <body> [base]"
    exit 1
fi

TITLE="$1"
BODY="$2"
BASE="${3:-main}"

gh pr create \
    --title "$TITLE" \
    --body "$BODY" \
    --base "$BASE"
