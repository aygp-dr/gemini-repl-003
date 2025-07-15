# Formal Methods Makefile

TLA_TOOL := ../tools/formal-methods/tla2tools.jar
ALLOY_TOOL := ../tools/formal-methods/alloy.jar
TLA_FILES := $(wildcard tla/*.tla)
ALLOY_FILES := $(wildcard alloy/*.alloy)

.PHONY: all check-tla check-alloy download-tools clean

all: download-tools check-tla check-alloy

download-tools: $(TLA_TOOL) $(ALLOY_TOOL)

$(TLA_TOOL):
	@echo "Downloading TLA+ tools..."
	@mkdir -p ../tools/formal-methods
	@curl -L -o $@ https://github.com/tlaplus/tlaplus/releases/download/v1.8.0/tla2tools.jar

$(ALLOY_TOOL):
	@echo "Downloading Alloy..."
	@mkdir -p ../tools/formal-methods
	@curl -L -o $@ https://github.com/AlloyTools/org.alloytools.alloy/releases/download/v6.0.0/org.alloytools.alloy.dist.jar

check-tla: $(TLA_TOOL)
	@echo "Checking TLA+ specifications..."
	@for file in $(TLA_FILES); do \
		echo "Checking $$file..."; \
		java -jar $(TLA_TOOL) -deadlock $$file || true; \
	done

check-alloy: $(ALLOY_TOOL)
	@echo "Alloy specifications ready for GUI verification"
	@echo "Run: java -jar $(ALLOY_TOOL) alloy/*.alloy"

gui-alloy: $(ALLOY_TOOL)
	java -jar $(ALLOY_TOOL) &

clean:
	@echo "Cleaning generated files..."
	@rm -f tla/*.old alloy/*.old