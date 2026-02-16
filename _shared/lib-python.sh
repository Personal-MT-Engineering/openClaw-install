#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - Python 3 + pip Installation
# ============================================================================

install_python_local() {
    header "Installing Python 3"

    local pkgs=()
    for name in python3 python3-pip python3-venv python3-dev; do
        local mapped
        mapped=$(pkg_name "$name")
        [[ -n "$mapped" ]] && pkgs+=($mapped)
    done

    if [[ ${#pkgs[@]} -gt 0 ]]; then
        pkg_install "${pkgs[@]}"
    fi

    log "Installing Python packages..."
    local pip_cmd="pip3"
    command -v pip3 &>/dev/null || pip_cmd="python3 -m pip"

    local pip_flags=""
    if python3 -c "import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)" 2>/dev/null; then
        pip_flags="--break-system-packages"
    fi

    $pip_cmd install $pip_flags --no-cache-dir \
        requests numpy pandas Pillow beautifulsoup4 flask fastapi httpx uvicorn 2>/dev/null || \
    sudo $pip_cmd install $pip_flags --no-cache-dir \
        requests numpy pandas Pillow beautifulsoup4 flask fastapi httpx uvicorn

    log "Python $(python3 --version 2>&1) installed"
}
