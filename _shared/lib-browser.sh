#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - Chromium + Xvfb + VNC + noVNC Installation
# ============================================================================

install_browser_local() {
    header "Installing Browser & Display Tools"

    if [[ "$OS_TYPE" == "macos" ]]; then
        if ! command -v chromium &>/dev/null && ! [[ -d "/Applications/Chromium.app" ]]; then
            brew install --cask chromium 2>/dev/null || warn "Could not install Chromium via brew"
        fi
        log "Browser tools installed (macOS - native display)"
        return
    fi

    local pkgs=()
    for name in chromium xvfb x11vnc fluxbox scrot fonts; do
        local mapped
        mapped=$(pkg_name "$name")
        [[ -n "$mapped" ]] && pkgs+=($mapped)
    done

    if [[ ${#pkgs[@]} -gt 0 ]]; then
        pkg_install "${pkgs[@]}"
    fi

    # Install noVNC from git
    if [[ ! -d /opt/novnc ]]; then
        log "Installing noVNC..."
        sudo git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc 2>/dev/null || true
        sudo git clone --depth 1 https://github.com/novnc/websockify.git /opt/novnc/utils/websockify 2>/dev/null || true
        sudo ln -sf /opt/novnc/vnc.html /opt/novnc/index.html 2>/dev/null || true
    fi

    log "Browser & display tools installed"
}

install_chromium_headless() {
    header "Installing Chromium (headless)"
    local mapped
    mapped=$(pkg_name "chromium")
    [[ -n "$mapped" ]] && pkg_install "$mapped"
}
