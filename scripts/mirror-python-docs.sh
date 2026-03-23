#!/bin/bash
# mirror-python-docs.sh — Download Python documentation for offline use
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Mirroring Python Documentation"

DEST=$(ensure_build_dir "docs/python")
PYTHON_VERSION="3.12"

# Python provides official downloadable docs
DOCS_URL="https://docs.python.org/${PYTHON_VERSION}/archives/python-${PYTHON_VERSION}-docs-html.tar.bz2"
ARCHIVE="${DEST}/python-${PYTHON_VERSION}-docs-html.tar.bz2"

download_file "$DOCS_URL" "$ARCHIVE" "Python ${PYTHON_VERSION} docs (HTML archive)"

# Extract if not already done
if [[ ! -d "${DEST}/python-${PYTHON_VERSION}-docs-html" ]]; then
    log_info "Extracting Python docs..."
    tar -xjf "$ARCHIVE" -C "$DEST"
    log_ok "Python docs extracted"
else
    log_info "Python docs already extracted"
fi

log_ok "Python docs ready: $(dir_size "$DEST")"
