#!/bin/bash
# download-portable-editors.sh — Download VS Code portable and extensions
set -euo pipefail
source "$(dirname "$0")/common.sh"

section "Downloading Portable Editors"

require_cmd curl

EDITOR_DIR=$(ensure_build_dir "editors")

# --- VS Code Portable ---
log_info "Downloading VS Code..."
VSCODE_DIR="${EDITOR_DIR}/vscode"
mkdir -p "$VSCODE_DIR"

# Windows portable zip
download_file \
    "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive" \
    "${VSCODE_DIR}/vscode-win32-x64.zip" \
    "VS Code Portable (Windows x64)" || \
    log_warn "VS Code Windows download failed — URL may have changed"

# Linux .tar.gz
download_file \
    "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" \
    "${VSCODE_DIR}/vscode-linux-x64.tar.gz" \
    "VS Code (Linux x64)" || \
    log_warn "VS Code Linux download failed — URL may have changed"

cat > "${VSCODE_DIR}/PORTABLE-SETUP.md" << 'EOF'
# VS Code Portable Mode

## Windows
1. Extract `vscode-win32-x64.zip`
2. Create a `data` folder inside the extracted directory
3. Launch `Code.exe` — it will use the `data` folder for all settings and extensions

## Linux
1. Extract `vscode-linux-x64.tar.gz`
2. Create a `data` folder inside the extracted directory
3. Run `./code` — portable mode activates automatically

## Installing Extensions Offline
1. Download .vsix files (see extensions/ folder)
2. In VS Code: Ctrl+Shift+P → "Install from VSIX..."
3. Select the .vsix file
EOF

# --- VS Code Extensions ---
log_info "Downloading VS Code extensions..."
EXT_DIR="${VSCODE_DIR}/extensions"
mkdir -p "$EXT_DIR"

# Extension marketplace API for downloading VSIX files
download_vsix() {
    local publisher="$1"
    local name="$2"
    local desc="${3:-${publisher}.${name}}"

    local url="https://${publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${name}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"

    download_file "$url" "${EXT_DIR}/${publisher}.${name}.vsix" "VS Code ext: $desc"
}

# Essential extensions for electronics/embedded development
download_vsix "platformio" "platformio-ide" "PlatformIO IDE"
download_vsix "ms-vscode" "cpptools" "C/C++ IntelliSense"
download_vsix "ms-python" "python" "Python"
download_vsix "ms-python" "vscode-pylance" "Pylance"
download_vsix "espressif" "esp-idf-extension" "ESP-IDF"
download_vsix "vsciot-vscode" "vscode-arduino" "Arduino"
download_vsix "yzhang" "markdown-all-in-one" "Markdown All in One"
download_vsix "ms-vscode-remote" "remote-ssh" "Remote SSH"
download_vsix "redhat" "vscode-yaml" "YAML"
download_vsix "DavidAnson" "vscode-markdownlint" "markdownlint"

# --- Micro editor (lightweight terminal editor) ---
log_info "Downloading micro editor..."
MICRO_DIR="${EDITOR_DIR}/micro"
mkdir -p "$MICRO_DIR"

MICRO_RELEASE=$(curl -fsSL "https://api.github.com/repos/zyedidia/micro/releases/latest" 2>/dev/null || echo "{}")

for pattern in "linux64-static.tar.gz" "win64.zip"; do
    URL=$(echo "$MICRO_RELEASE" | grep -o "\"browser_download_url\": *\"[^\"]*${pattern}\"" | head -1 | cut -d'"' -f4 || true)
    if [[ -n "$URL" ]]; then
        download_file "$URL" "${MICRO_DIR}/$(basename "$URL")" "micro editor (${pattern})"
    fi
done

echo ""
log_ok "Editor downloads complete!"
log_info "Total editors size: $(dir_size "$EDITOR_DIR")"
