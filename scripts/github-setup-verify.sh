#!/bin/sh
# Verify GitHub setup completed successfully

echo "Verifying GitHub integration setup..."

# Check directories
for dir in .github .github/workflows .github/ISSUE_TEMPLATE .github/rfcs .github/scripts; do
    if [ -d "$dir" ]; then
        echo "✓ $dir exists"
    else
        echo "✗ $dir missing"
        exit 1
    fi
done

# Check workflow files
for workflow in ci.yml formal-verification.yml release.yml docs.yml; do
    if [ -f ".github/workflows/$workflow" ]; then
        echo "✓ $workflow workflow exists"
    else
        echo "✗ $workflow workflow missing"
        exit 1
    fi
done

# Check templates
for template in bug_report.yml feature_request.yml rfc.yml; do
    if [ -f ".github/ISSUE_TEMPLATE/$template" ]; then
        echo "✓ $template template exists"
    else
        echo "✗ $template template missing"
        exit 1
    fi
done

echo ""
echo "GitHub integration setup verified successfully!"
echo "Note: No GitHub repository required - structure ready for when needed"
