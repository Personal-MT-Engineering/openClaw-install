#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - Email Tools (msmtp, mailutils)
# ============================================================================

install_email_local() {
    header "Installing Email Tools"

    local pkgs=()
    for name in msmtp mailutils; do
        local mapped
        mapped=$(pkg_name "$name")
        [[ -n "$mapped" ]] && pkgs+=($mapped)
    done

    if [[ ${#pkgs[@]} -gt 0 ]]; then
        pkg_install "${pkgs[@]}"
    fi

    log "Email tools installed"
}
