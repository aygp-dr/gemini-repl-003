# Development Guide

## Prerequisites
- Node.js (v16 or later)
- npm or yarn
- Gemini API key

## Setup
1. Clone the repository
2. Copy `.env.example` to `.env` and add your API key
3. Run `npm install`
4. Run `npm run build`

## Development Commands
- `npm run dev` - Start development with hot reload
- `npm run build` - Build production version
- `npm run test` - Run tests
- `npm run repl` - Start ClojureScript REPL

## Project Structure
```
src/
└── gemini_repl/
    └── core.cljs      # Main REPL implementation
test/
└── gemini_repl/
    ├── test_runner.cljs
    └── core_test.cljs
```

## Key Features
- Slash command system
- Gemini API integration
- Usage statistics tracking
- Debug mode
- Conversation context (to be implemented)
