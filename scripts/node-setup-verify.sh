#!/usr/bin/env sh
# Verify Node.js setup completed successfully

echo "Verifying Node.js and ClojureScript setup..."

# Check files
for file in package.json shadow-cljs.edn; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
        exit 1
    fi
done

# Check source files
if [ -f "src/gemini_repl/core.cljs" ]; then
    echo "✓ Core implementation exists"
else
    echo "✗ Core implementation missing"
    exit 1
fi

# Check scripts
for script in build.sh dev.sh run.sh node-setup-verify.sh; do
    if [ -f "scripts/$script" ]; then
        echo "✓ scripts/$script exists"
    else
        echo "✗ scripts/$script missing"
        exit 1
    fi
done

echo ""
echo "Node.js setup verified successfully!"
echo "Next step: npm install"
