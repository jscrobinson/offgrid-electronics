.PHONY: all docs mirror toolchains editors sdr chirp docker packages usb usb-lite verify size clean

SHELL := /bin/bash
USB ?= /mnt/e
BUILD := build
SCRIPTS := scripts

# Default: build everything
all: docs mirror toolchains editors sdr chirp docker packages datasheets

# Authored docs are already in docs/ — nothing to build
docs:
	@echo "Authored docs are in docs/ — no build step needed."
	@echo "Run 'make mirror' to download external documentation."

# Mirror external documentation
mirror:
	bash $(SCRIPTS)/download-docs.sh

# Download toolchains (Arduino IDE, ESP-IDF, PlatformIO)
toolchains:
	bash $(SCRIPTS)/download-toolchains.sh

# Download portable editors (VS Code portable + extensions)
editors:
	bash $(SCRIPTS)/download-portable-editors.sh

# Download SDR software
sdr:
	bash $(SCRIPTS)/download-sdr-software.sh

# Download CHIRP
chirp:
	bash $(SCRIPTS)/download-chirp.sh

# Download and save Docker images
docker:
	bash $(SCRIPTS)/download-docker-images.sh

# Cache npm and pip packages
packages:
	bash $(SCRIPTS)/download-npm-packages.sh
	bash $(SCRIPTS)/download-pip-packages.sh

# Download datasheets
datasheets:
	bash $(SCRIPTS)/download-datasheets.sh

# Assemble USB stick (full — requires 64 GB)
usb:
	@if [ -z "$(USB)" ] || [ ! -d "$(USB)" ]; then \
		echo "Error: USB mount point not found. Usage: make usb USB=/mnt/e"; \
		exit 1; \
	fi
	bash $(SCRIPTS)/build-usb.sh "$(USB)" full

# Lite USB (no Docker images — fits 32 GB)
usb-lite:
	@if [ -z "$(USB)" ] || [ ! -d "$(USB)" ]; then \
		echo "Error: USB mount point not found. Usage: make usb-lite USB=/mnt/e"; \
		exit 1; \
	fi
	bash $(SCRIPTS)/build-usb.sh "$(USB)" lite

# Verify USB contents
verify:
	@if [ -z "$(USB)" ] || [ ! -d "$(USB)" ]; then \
		echo "Error: USB mount point not found. Usage: make verify USB=/mnt/e"; \
		exit 1; \
	fi
	bash $(SCRIPTS)/verify-usb.sh "$(USB)"

# Show total size of build directory
size:
	@echo "Build directory sizes:"
	@du -sh $(BUILD)/*/ 2>/dev/null || echo "  (build directory is empty — run 'make all' first)"
	@echo ""
	@du -sh $(BUILD)/ 2>/dev/null || echo "  Total: 0"
	@echo ""
	@echo "Authored docs:"
	@du -sh docs/

# Clean build artifacts
clean:
	rm -rf $(BUILD)/*
	@echo "Build directory cleaned."
