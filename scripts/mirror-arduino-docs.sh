#!/bin/bash
# mirror-arduino-docs.sh — Download Arduino reference for offline use
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Mirroring Arduino Documentation"

DEST=$(ensure_build_dir "docs/arduino")

# Arduino reference is available as a GitHub repo
REPO_URL="https://github.com/arduino/reference-en.git"
REPO_DIR="${DEST}/reference-en"

if [[ -d "$REPO_DIR/.git" ]]; then
    log_info "Updating existing Arduino reference clone..."
    git -C "$REPO_DIR" pull --ff-only || log_warn "Git pull failed, using existing version"
else
    log_info "Cloning Arduino reference..."
    require_cmd git
    git clone --depth 1 "$REPO_URL" "$REPO_DIR"
fi

# Also download the Arduino Language Reference as single pages
log_info "Downloading Arduino cheat sheet resources..."

download_file "https://docs.arduino.cc/built-in-examples/" \
    "${DEST}/built-in-examples.html" "Arduino built-in examples index" || true

log_ok "Arduino docs ready: $(dir_size "$DEST")"
