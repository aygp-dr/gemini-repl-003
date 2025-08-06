# Gemini REPL Makefile
# Use gmake on FreeBSD

# Project configuration
PROJECT_NAME ?= gemini-repl
PROJECT_ROOT ?= $(shell pwd)

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
	@echo "  make emacs    - Start Emacs in tmux for Clojure development"
	@echo "  make attach   - Attach to existing Emacs tmux session"
	@echo "  make tty      - Show TTY of Emacs tmux pane"

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

.PHONY: verify
verify:
	$(MAKE) -C specs check-tla
	$(MAKE) -C specs check-alloy

.PHONY: download-tla
download-tla:
	$(MAKE) -C specs download-tools

.PHONY: download-alloy
download-alloy:
	$(MAKE) -C specs download-tools

.PHONY: all
all: lint test build
	@echo "Quality gates passed!"

# Emacs/tmux support for Clojure development
.PHONY: emacs
emacs:
	@if tmux has-session -t $(PROJECT_NAME) 2>/dev/null; then \
		echo "Session $(PROJECT_NAME) already exists. Use 'make attach' to connect."; \
	else \
		echo "Starting Emacs in tmux session: $(PROJECT_NAME)"; \
		tmux new-session -d -s $(PROJECT_NAME) "emacs -nw -Q -l $(PROJECT_ROOT)/$(PROJECT_NAME).el"; \
		echo "Session started. Use 'make attach' to connect."; \
	fi

.PHONY: attach
attach:
	@if tmux has-session -t $(PROJECT_NAME) 2>/dev/null; then \
		tmux attach-session -t $(PROJECT_NAME); \
	else \
		echo "No session found. Use 'make emacs' to start one."; \
	fi

.PHONY: tty
tty:
	@if tmux has-session -t $(PROJECT_NAME) 2>/dev/null; then \
		tmux list-panes -t $(PROJECT_NAME) -F "#{pane_tty}"; \
	else \
		echo "No session found. Use 'make emacs' to start one."; \
	fi
