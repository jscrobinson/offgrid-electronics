#!/bin/bash
# mirror-meshtastic-docs.sh — Download Meshtastic documentation for offline use
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Mirroring Meshtastic Documentation"

DEST=$(ensure_build_dir "docs/meshtastic")

# Clone the Meshtastic documentation site source
REPO_URL="https://github.com/meshtastic/meshtastic.git"
REPO_DIR="${DEST}/meshtastic-docs"

if [[ -d "$REPO_DIR/.git" ]]; then
    log_info "Updating existing Meshtastic docs clone..."
    git -C "$REPO_DIR" pull --ff-only || log_warn "Git pull failed, using existing version"
else
    log_info "Cloning Meshtastic documentation..."
    require_cmd git
    git clone --depth 1 "$REPO_URL" "$REPO_DIR"
fi

# Also download the latest firmware release info
FIRMWARE_DIR="${DEST}/firmware-info"
mkdir -p "$FIRMWARE_DIR"

log_info "Fetching latest Meshtastic firmware release info..."
if command -v curl &>/dev/null; then
    curl -fsSL "https://api.github.com/repos/meshtastic/firmware/releases/latest" \
        > "${FIRMWARE_DIR}/latest-release.json" 2>/dev/null || \
        log_warn "Could not fetch firmware release info"
fi

# Download the Meshtastic Python CLI docs
download_file "https://raw.githubusercontent.com/meshtastic/python/master/README.md" \
    "${DEST}/meshtastic-python-readme.md" "Meshtastic Python CLI README" || true

log_ok "Meshtastic docs ready: $(dir_size "$DEST")"
