#!/bin/bash
# mirror-esp-idf-docs.sh — Download ESP-IDF documentation for offline use
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Mirroring ESP-IDF Documentation"

DEST=$(ensure_build_dir "docs/esp-idf")
IDF_VERSION="v5.2.1"

# ESP-IDF docs can be built from source or downloaded as PDF
# The HTML docs are large; we'll grab the PDF version and key HTML pages

# Download ESP-IDF Programming Guide PDF
PDF_URL="https://docs.espressif.com/projects/esp-idf/en/${IDF_VERSION}/esp-idf-en-${IDF_VERSION}-esp32.pdf"
download_file "$PDF_URL" "${DEST}/esp-idf-${IDF_VERSION}-esp32.pdf" \
    "ESP-IDF Programming Guide PDF (ESP32)" || true

# ESP32-S3 variant
PDF_S3_URL="https://docs.espressif.com/projects/esp-idf/en/${IDF_VERSION}/esp-idf-en-${IDF_VERSION}-esp32s3.pdf"
download_file "$PDF_S3_URL" "${DEST}/esp-idf-${IDF_VERSION}-esp32s3.pdf" \
    "ESP-IDF Programming Guide PDF (ESP32-S3)" || true

# ESP32-C3 variant
PDF_C3_URL="https://docs.espressif.com/projects/esp-idf/en/${IDF_VERSION}/esp-idf-en-${IDF_VERSION}-esp32c3.pdf"
download_file "$PDF_C3_URL" "${DEST}/esp-idf-${IDF_VERSION}-esp32c3.pdf" \
    "ESP-IDF Programming Guide PDF (ESP32-C3)" || true

# Clone the ESP-IDF examples (lightweight — just examples, not full IDF)
EXAMPLES_DIR="${DEST}/examples"
if [[ -d "$EXAMPLES_DIR/.git" ]]; then
    log_info "ESP-IDF examples already cloned"
else
    log_info "Cloning ESP-IDF examples (sparse checkout)..."
    require_cmd git
    git clone --depth 1 --filter=blob:none --sparse \
        "https://github.com/espressif/esp-idf.git" "$EXAMPLES_DIR" || {
        log_warn "Sparse clone failed, skipping examples"
    }
    if [[ -d "$EXAMPLES_DIR/.git" ]]; then
        cd "$EXAMPLES_DIR"
        git sparse-checkout set examples/
        cd - > /dev/null
    fi
fi

log_ok "ESP-IDF docs ready: $(dir_size "$DEST")"
