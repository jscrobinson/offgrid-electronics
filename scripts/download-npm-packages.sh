#!/bin/bash
# download-npm-packages.sh — Cache npm packages for offline installation
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Downloading npm Packages"

require_cmd npm

PKG_DIR=$(ensure_build_dir "packages/npm")
PKG_LIST="${CONFIG_DIR}/packages-npm.txt"

if [[ ! -f "$PKG_LIST" ]]; then
    log_error "Package list not found: $PKG_LIST"
    exit 1
fi

log_info "Reading package list from: $PKG_LIST"

# Create a temporary directory for packing
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

while IFS= read -r package || [[ -n "$package" ]]; do
    # Skip empty lines and comments
    [[ -z "$package" || "$package" == \#* ]] && continue

    log_info "Packing: $package"
    if (cd "$TEMP_DIR" && npm pack "$package" 2>/dev/null); then
        # Move the .tgz file to our packages directory
        mv "$TEMP_DIR"/*.tgz "$PKG_DIR/" 2>/dev/null || true
        log_ok "Packed: $package"
    else
        log_warn "Failed to pack: $package"
    fi
done < "$PKG_LIST"

echo ""
log_ok "npm packages cached!"
log_info "Total npm packages size: $(dir_size "$PKG_DIR")"

echo ""
echo "To install offline:"
echo "  npm install --offline <package-name>"
echo "  # Or point npm to local cache:"
echo "  npm install --cache ${PKG_DIR} <package-name>"
echo ""
echo "Cached packages:"
ls "${PKG_DIR}"/*.tgz 2>/dev/null | xargs -I{} basename {} | head -20
