#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - Tor + torsocks Installation
# ============================================================================

install_tor_local() {
    header "Installing Tor"

    local pkgs=()
    for name in tor torsocks; do
        local mapped
        mapped=$(pkg_name "$name")
        [[ -n "$mapped" ]] && pkgs+=($mapped)
    done

    if [[ ${#pkgs[@]} -gt 0 ]]; then
        pkg_install "${pkgs[@]}"
    fi

    # Configure torrc
    local torrc="/etc/tor/torrc"
    if [[ -f "$torrc" ]]; then
        if ! grep -q "SocksPort 0.0.0.0:9050" "$torrc" 2>/dev/null; then
            echo "SocksPort 0.0.0.0:9050" | sudo tee -a "$torrc" > /dev/null
        fi
    fi

    log "Tor installed"
}
