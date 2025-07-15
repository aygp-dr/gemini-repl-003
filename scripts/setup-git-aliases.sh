#!/bin/sh
# Setup useful git aliases for the project

echo "Setting up git aliases..."

# Add git notes alias
git config alias.notes-log 'log --show-notes=*'

# Add commit with trailer alias
git config alias.commit-signed 'commit --trailer "Co-Authored-By: Claude <noreply@anthropic.com>"'

# Show current phase
git config alias.show-phase 'log --oneline -n 20 --grep="Phase"'

echo "Git aliases configured successfully"
