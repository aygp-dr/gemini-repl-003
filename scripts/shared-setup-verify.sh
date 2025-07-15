#!/usr/bin/env sh
# Verify shared setup completed successfully

echo "Verifying shared infrastructure setup..."

# Check directories
for dir in .claude/commands change-requests experiments research; do
    if [ -d "$dir" ]; then
        echo "✓ $dir exists"
    else
        echo "✗ $dir missing"
        exit 1
    fi
done

# Check command files
for cmd in analyze create-cr experiment github implement mise-en-place research spec-check; do
    if [ -f ".claude/commands/$cmd.md" ]; then
        echo "✓ $cmd.md command exists"
    else
        echo "✗ $cmd.md command missing"
        exit 1
    fi
done

echo ""
echo "Shared infrastructure setup verified successfully!"
