# Gemini REPL Makefile
# Use gmake on FreeBSD

.PHONY: help
help:
	@echo "Gemini REPL Build System"
	@echo "========================"
	@echo "Available targets:"
	@echo "  make help     - Show this help message"
	@echo "  make setup    - Initial project setup"
	@echo "  make install  - Install dependencies"
	@echo "  make build    - Build the application"
	@echo "  make dev      - Run in development mode with live reload"
	@echo "  make run      - Run the REPL"
	@echo "  make test     - Run tests"
	@echo "  make lint     - Run linter"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make all      - Run lint, test, and build"

.PHONY: setup
setup:
	@echo "Setting up project structure..."
	@test -d specs || mkdir -p specs
	@test -d src || mkdir -p src
	@test -d tests || mkdir -p tests
	@test -d docs || mkdir -p docs
	@test -d scripts || mkdir -p scripts
	@test -d tools || mkdir -p tools
	@echo "Project structure created successfully"

.PHONY: install
install:
	npm install

.PHONY: build
build:
	npm run build

.PHONY: dev
dev:
	npm run dev

.PHONY: run
run:
	@if [ ! -f target/main.js ]; then \
		echo "Building first..."; \
		npm run build; \
	fi
	node target/main.js

.PHONY: test
test:
	npm test

.PHONY: lint
lint:
	npx clj-kondo --lint src test

.PHONY: clean
clean:
	npm run clean
	rm -rf node_modules

.PHONY: all
all: lint test build
	@echo "Quality gates passed!"
