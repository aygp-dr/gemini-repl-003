#!/usr/bin/env sh
# Check the status of GitHub Actions workflows

echo "Recent workflow runs:"
gh run list --limit 10

echo ""
echo "Active workflows:"
gh workflow list
