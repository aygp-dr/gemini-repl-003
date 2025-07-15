#!/bin/sh
# Project setup script

echo "Gemini REPL Project Setup"
echo "========================"

# Check for required tools
check_tool() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "ERROR: $1 is not installed"
        return 1
    else
        echo "✓ $1 found"
        return 0
    fi
}

echo ""
echo "Checking required tools..."
check_tool git
check_tool node
check_tool npm

echo ""
echo "Project structure:"
find . -type d -name ".*" -prune -o -type d -print | head -20

echo ""
echo "Setup complete!"
