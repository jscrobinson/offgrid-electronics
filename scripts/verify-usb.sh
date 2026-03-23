#!/bin/bash
# verify-usb.sh — Verify USB stick integrity using MANIFEST.txt checksums
set -euo pipefail
source "$(dirname "$0")/common.sh"

USB_MOUNT="${1:?Usage: verify-usb.sh /mnt/usb}"

section "Verifying USB Stick Integrity"

MANIFEST="${USB_MOUNT}/MANIFEST.txt"

if [[ ! -f "$MANIFEST" ]]; then
    log_error "MANIFEST.txt not found at: $MANIFEST"
    log_error "Run 'make usb' first to generate the manifest."
    exit 1
fi

log_info "Verifying checksums from: $MANIFEST"
log_info "Total files to verify: $(wc -l < "$MANIFEST")"

# Run sha256sum check
cd "$USB_MOUNT"

FAIL_COUNT=0
PASS_COUNT=0
TOTAL=$(wc -l < "$MANIFEST")

while IFS=' ' read -r expected_hash filepath; do
    [[ -z "$expected_hash" || -z "$filepath" ]] && continue
    # Remove leading ./ or * from filepath (sha256sum formats vary)
    filepath="${filepath#\*}"
    filepath="${filepath# }"

    if [[ ! -f "$filepath" ]]; then
        log_error "MISSING: $filepath"
        ((FAIL_COUNT++))
        continue
    fi

    actual_hash=$(sha256sum "$filepath" | cut -d' ' -f1)
    if [[ "$actual_hash" == "$expected_hash" ]]; then
        ((PASS_COUNT++))
    else
        log_error "MISMATCH: $filepath"
        log_error "  Expected: $expected_hash"
        log_error "  Actual:   $actual_hash"
        ((FAIL_COUNT++))
    fi
done < "$MANIFEST"

echo ""
section "Verification Results"
log_info "Total files:  $TOTAL"
log_ok   "Passed:       $PASS_COUNT"

if (( FAIL_COUNT > 0 )); then
    log_error "Failed:       $FAIL_COUNT"
    echo ""
    log_error "VERIFICATION FAILED — some files are corrupted or missing"
    exit 1
else
    log_ok "Failed:       0"
    echo ""
    log_ok "ALL FILES VERIFIED SUCCESSFULLY"
fi
