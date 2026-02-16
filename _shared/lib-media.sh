#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - Media Processing Tools
# ffmpeg, imagemagick, sox, libvips
# ============================================================================

install_media_local() {
    header "Installing Media Processing Tools"

    local pkgs=()
    pkgs+=(ffmpeg)
    for name in imagemagick sox libvips-dev; do
        local mapped
        mapped=$(pkg_name "$name")
        [[ -n "$mapped" ]] && pkgs+=($mapped)
    done

    pkg_install "${pkgs[@]}"
    log "Media tools installed (ffmpeg, imagemagick, sox, libvips)"
}
