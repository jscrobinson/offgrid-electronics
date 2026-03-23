#!/bin/bash
# mirror-devdocs.sh — Download DevDocs for offline use
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Downloading DevDocs Offline Bundle"

DEST=$(ensure_build_dir "docs/devdocs")

# DevDocs can be self-hosted — clone the repo and build, or use the PWA approach
REPO_URL="https://github.com/freeCodeCamp/devdocs.git"
REPO_DIR="${DEST}/devdocs"

if [[ -d "$REPO_DIR/.git" ]]; then
    log_info "DevDocs repo already cloned"
else
    log_info "Cloning DevDocs repository..."
    log_info "Note: DevDocs is ~2GB. This may take a while."
    require_cmd git
    git clone --depth 1 "$REPO_URL" "$REPO_DIR"
fi

cat > "${DEST}/README.md" << 'EOF'
# DevDocs Offline

DevDocs (devdocs.io) provides offline-capable documentation for many languages and frameworks.

## Option 1: Use the PWA (easiest)
1. Visit https://devdocs.io while online
2. Click the menu → Offline → select the docs you want
3. They'll be cached in your browser for offline use

## Option 2: Self-host from this clone
1. Install Ruby and Bundler
2. cd devdocs && bundle install
3. bundle exec thor docs:download --all (or specific: --doc python~3.12)
4. bundle exec rackup
5. Open http://localhost:9292

## Recommended docs to download:
- Python 3.12
- Node.js 20 LTS
- JavaScript
- HTML/CSS
- C
- Bash
- Git
- Markdown
EOF

log_ok "DevDocs ready: $(dir_size "$DEST")"
