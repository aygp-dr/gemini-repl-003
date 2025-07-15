# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the Gemini REPL codebase.

## Project Overview
A ClojureScript REPL application that interfaces with Google's Gemini API for conversational AI interactions.

## Build & Test Commands
- **Setup**: `gmake install` (FreeBSD) or `make install` (Linux/macOS)
- **Build**: `gmake build` - Compiles ClojureScript to JavaScript
- **Test**: `gmake test` - Runs unit tests
- **Lint**: `gmake lint` - Runs clj-kondo linter
- **Run**: `gmake run` - Starts the REPL (requires GEMINI_API_KEY)
- **Dev**: `gmake dev` - Starts Shadow-CLJS watch mode

## Environment Setup
- Use direnv with `.envrc` for automatic environment loading
- Copy `.env.example` to `.env` and add your Gemini API key
- Required: `GEMINI_API_KEY` environment variable

## Code Style Guidelines
- **ClojureScript**: Follow standard Clojure style guide
- **Namespaces**: Use descriptive names (e.g., `gemini-repl.core`)
- **Functions**: Pure functions preferred, side effects clearly marked
- **State**: Use atoms for mutable state, minimize global state
- **Testing**: Write tests for all public functions
- **Documentation**: Include docstrings for public functions

## Project Structure
```
.
├── src/gemini_repl/      # Source code
├── test/gemini_repl/     # Unit tests
├── scripts/              # Utility scripts (expect tests)
├── specs/                # Formal specifications (TLA+, Alloy)
├── shadow-cljs.edn       # ClojureScript build config
├── .clj-kondo/          # Linter configuration
└── Makefile             # Build automation
```

## Key Files
- `src/gemini_repl/core.cljs` - Main REPL implementation
- `shadow-cljs.edn` - Build configuration
- `package.json` - Node.js dependencies
- `.envrc` - direnv configuration

## Development Notes
- Shadow-CLJS is used for ClojureScript compilation
- Node.js target for command-line execution
- Expect scripts for integration testing
- Formal verification with TLA+ and Alloy specifications