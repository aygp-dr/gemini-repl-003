#!/usr/bin/env sh
# Build the ClojureScript application

echo "Building Gemini REPL..."
npx shadow-cljs compile app

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "Run with: node target/main.js"
else
    echo "Build failed!"
    exit 1
fi
