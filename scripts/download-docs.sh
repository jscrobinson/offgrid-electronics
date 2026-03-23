#!/bin/bash
# download-docs.sh — Master script: mirrors all external documentation
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Downloading External Documentation"

SCRIPTS_DIR="$(dirname "$0")"

# Run each mirror script
scripts=(
    "mirror-python-docs.sh"
    "mirror-nodejs-docs.sh"
    "mirror-arduino-docs.sh"
    "mirror-esp-idf-docs.sh"
    "mirror-meshtastic-docs.sh"
    "mirror-devdocs.sh"
)

failed=0
for script in "${scripts[@]}"; do
    script_path="${SCRIPTS_DIR}/${script}"
    if [[ -x "$script_path" ]]; then
        log_info "Running: $script"
        if bash "$script_path"; then
            log_ok "Completed: $script"
        else
            log_error "Failed: $script"
            ((failed++))
        fi
    else
        log_warn "Script not found or not executable: $script"
        ((failed++))
    fi
done

echo ""
if (( failed > 0 )); then
    log_warn "$failed script(s) had errors. Check output above."
else
    log_ok "All documentation mirrors completed successfully."
fi

log_info "Total mirrored docs size: $(dir_size "${BUILD_DIR}/docs")"
