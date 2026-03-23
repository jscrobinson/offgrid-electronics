#!/bin/bash
# download-pip-packages.sh — Cache pip packages for offline installation
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Downloading pip Packages"

require_cmd pip3

PKG_DIR=$(ensure_build_dir "packages/pip")
PKG_LIST="${CONFIG_DIR}/packages-pip.txt"

if [[ ! -f "$PKG_LIST" ]]; then
    log_error "Package list not found: $PKG_LIST"
    exit 1
fi

log_info "Reading package list from: $PKG_LIST"
log_info "Downloading packages and dependencies..."

# Read all packages into an array
packages=()
while IFS= read -r package || [[ -n "$package" ]]; do
    [[ -z "$package" || "$package" == \#* ]] && continue
    packages+=("$package")
done < "$PKG_LIST"

# Download all packages with dependencies
if (( ${#packages[@]} > 0 )); then
    log_info "Downloading ${#packages[@]} packages (plus dependencies)..."
    pip3 download \
        --dest "$PKG_DIR" \
        "${packages[@]}" || {
        log_warn "Some packages failed to download. Trying individually..."

        for package in "${packages[@]}"; do
            log_info "Downloading: $package"
            pip3 download --dest "$PKG_DIR" "$package" 2>/dev/null || \
                log_warn "Failed: $package"
        done
    }
fi

echo ""
log_ok "pip packages cached!"
log_info "Total pip packages size: $(dir_size "$PKG_DIR")"

echo ""
echo "To install offline:"
echo "  pip install --no-index --find-links ${PKG_DIR} <package-name>"
echo ""
echo "Cached packages:"
ls "${PKG_DIR}"/*.whl "${PKG_DIR}"/*.tar.gz 2>/dev/null | xargs -I{} basename {} | head -20
