#!/bin/bash
# download-docker-images.sh — Pull and save Docker images for offline use
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Downloading Docker Images"

require_cmd docker

DOCKER_DIR=$(ensure_build_dir "docker")
IMAGE_LIST="${CONFIG_DIR}/docker-images.txt"

if [[ ! -f "$IMAGE_LIST" ]]; then
    log_error "Image list not found: $IMAGE_LIST"
    exit 1
fi

# Check Docker daemon is running
if ! docker info &>/dev/null; then
    log_error "Docker daemon is not running. Start Docker and try again."
    exit 1
fi

log_info "Reading image list from: $IMAGE_LIST"

while IFS= read -r image || [[ -n "$image" ]]; do
    # Skip empty lines and comments
    [[ -z "$image" || "$image" == \#* ]] && continue

    # Generate a safe filename from the image name
    safe_name=$(echo "$image" | tr '/:' '-')
    tar_file="${DOCKER_DIR}/${safe_name}.tar"

    if [[ -f "$tar_file" ]]; then
        log_info "Already saved: $image"
        continue
    fi

    log_info "Pulling: $image"
    if docker pull "$image"; then
        log_info "Saving: $image → ${safe_name}.tar"
        docker save -o "$tar_file" "$image"
        log_ok "Saved: $image ($(file_size "$tar_file"))"
    else
        log_error "Failed to pull: $image"
    fi
done < "$IMAGE_LIST"

echo ""
log_ok "Docker images saved!"
log_info "Total Docker images size: $(dir_size "$DOCKER_DIR")"

echo ""
echo "To load an image offline:"
echo "  docker load < ${DOCKER_DIR}/IMAGE_NAME.tar"
echo ""
echo "Saved images:"
ls -lh "${DOCKER_DIR}"/*.tar 2>/dev/null | awk '{print "  " $NF ": " $5}'
