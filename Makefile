# Gemini REPL Makefile
# Use gmake on FreeBSD

.PHONY: help
help:
	@echo "Gemini REPL Build System"
	@echo "========================"
	@echo "Available targets:"
	@echo "  make help     - Show this help message"
	@echo "  make setup    - Initial project setup"
	@echo ""
	@echo "More targets will be added as the project develops"

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
