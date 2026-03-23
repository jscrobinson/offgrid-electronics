#!/bin/bash
# download-datasheets.sh — Download component datasheets
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Downloading Datasheets"

require_cmd curl

DS_DIR=$(ensure_build_dir "datasheets")
DS_LIST="${CONFIG_DIR}/datasheets.txt"

if [[ ! -f "$DS_LIST" ]]; then
    log_error "Datasheet list not found: $DS_LIST"
    log_info "Create $DS_LIST with lines in format: FILENAME URL"
    exit 1
fi

log_info "Reading datasheet list from: $DS_LIST"

count=0
failed=0

while IFS=' ' read -r filename url rest || [[ -n "$filename" ]]; do
    # Skip empty lines and comments
    [[ -z "$filename" || "$filename" == \#* ]] && continue

    if [[ -z "$url" ]]; then
        log_warn "No URL for: $filename"
        continue
    fi

    if download_file "$url" "${DS_DIR}/${filename}" "$filename"; then
        ((count++))
    else
        ((failed++))
    fi
done < "$DS_LIST"

echo ""
log_ok "Datasheets downloaded: $count succeeded, $failed failed"
log_info "Total datasheets size: $(dir_size "$DS_DIR")"
