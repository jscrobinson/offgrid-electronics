#!/bin/bash
# mirror-nodejs-docs.sh — Download Node.js documentation for offline use
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Mirroring Node.js Documentation"

DEST=$(ensure_build_dir "docs/nodejs")
NODE_VERSION="v20.11.1"

# Download the full Node.js docs directory
log_info "Downloading Node.js API docs..."

# The most reliable approach: download the doc pages from the release
BASE_URL="https://nodejs.org/dist/${NODE_VERSION}/docs/api"

# Download the main index
download_file "https://nodejs.org/dist/${NODE_VERSION}/docs/api.html" \
    "${DEST}/api.html" "Node.js API index"

# Download individual API docs (key modules)
API_PAGES=(
    assert buffer child_process cluster console crypto dgram dns
    errors events fs http http2 https inspector modules net os
    path perf_hooks process querystring readline repl stream
    string_decoder timers tls tty url util v8 vm worker_threads zlib
)

for page in "${API_PAGES[@]}"; do
    download_file "${BASE_URL}/${page}.html" \
        "${DEST}/api/${page}.html" "Node.js API: ${page}"
done

# Also try to get the JSON versions for programmatic use
for page in "${API_PAGES[@]}"; do
    download_file "${BASE_URL}/${page}.json" \
        "${DEST}/api/${page}.json" "Node.js API JSON: ${page}" || true
done

log_ok "Node.js docs ready: $(dir_size "$DEST")"
