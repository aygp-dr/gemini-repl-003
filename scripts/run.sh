#!/usr/bin/env sh
# Run the compiled application

if [ ! -f target/main.js ]; then
    echo "Application not built. Running build first..."
    ./scripts/build.sh
fi

echo "Starting Gemini REPL..."
node target/main.js
