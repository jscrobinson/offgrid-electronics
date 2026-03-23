#!/bin/bash
# common.sh — Shared functions for all download/build scripts
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root (parent of scripts/)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"
CONFIG_DIR="${PROJECT_ROOT}/config"

# Logging
log_info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Check if a command exists
require_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        log_error "Required command not found: $cmd"
        exit 1
    fi
}

# Check available disk space (in MB)
check_disk_space() {
    local dir="$1"
    local required_mb="$2"
    local available_mb
    available_mb=$(df -m "$dir" | awk 'NR==2 {print $4}')
    if (( available_mb < required_mb )); then
        log_error "Insufficient disk space in $dir: ${available_mb}MB available, ${required_mb}MB required"
        return 1
    fi
    log_info "Disk space OK: ${available_mb}MB available (need ${required_mb}MB)"
}

# Download a file with retry logic
# Usage: download_file URL DEST_PATH [DESCRIPTION]
download_file() {
    local url="$1"
    local dest="$2"
    local desc="${3:-$(basename "$dest")}"
    local max_retries=3
    local retry_delay=5

    # Skip if already downloaded
    if [[ -f "$dest" ]]; then
        log_info "Already exists: $desc"
        return 0
    fi

    mkdir -p "$(dirname "$dest")"

    for (( i=1; i<=max_retries; i++ )); do
        log_info "Downloading ($i/$max_retries): $desc"
        if curl -fSL --connect-timeout 30 --max-time 600 -o "$dest.tmp" "$url"; then
            mv "$dest.tmp" "$dest"
            log_ok "Downloaded: $desc"
            return 0
        fi
        log_warn "Attempt $i failed for: $desc"
        rm -f "$dest.tmp"
        if (( i < max_retries )); then
            sleep "$retry_delay"
            retry_delay=$((retry_delay * 2))
        fi
    done

    log_error "Failed to download after $max_retries attempts: $desc"
    log_error "  URL: $url"
    return 1
}

# Download a file using wget (for mirroring)
# Usage: wget_mirror URL DEST_DIR [EXTRA_ARGS...]
wget_mirror() {
    local url="$1"
    local dest_dir="$2"
    shift 2
    local extra_args=("$@")

    require_cmd wget
    mkdir -p "$dest_dir"

    log_info "Mirroring: $url"
    wget --mirror \
         --convert-links \
         --adjust-extension \
         --page-requisites \
         --no-parent \
         --directory-prefix="$dest_dir" \
         --no-host-directories \
         --timeout=30 \
         --tries=3 \
         --wait=1 \
         "${extra_args[@]}" \
         "$url" || {
        log_warn "wget mirror completed with some errors (this is often normal)"
    }
}

# Generate SHA256 checksum for a file
checksum_file() {
    local file="$1"
    sha256sum "$file"
}

# Generate checksums for all files in a directory
generate_checksums() {
    local dir="$1"
    local manifest="$2"

    log_info "Generating checksums for: $dir"
    find "$dir" -type f ! -name "MANIFEST.txt" -print0 \
        | sort -z \
        | xargs -0 sha256sum \
        > "$manifest"
    log_ok "Manifest written: $manifest ($(wc -l < "$manifest") files)"
}

# Get file size in human-readable format
file_size() {
    local file="$1"
    du -sh "$file" | cut -f1
}

# Get directory size in human-readable format
dir_size() {
    local dir="$1"
    du -sh "$dir" | cut -f1
}

# Ensure build subdirectory exists
ensure_build_dir() {
    local subdir="$1"
    mkdir -p "${BUILD_DIR}/${subdir}"
    echo "${BUILD_DIR}/${subdir}"
}

# Print a section header
section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $*${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}
