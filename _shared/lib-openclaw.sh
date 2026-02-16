#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - OpenClaw Installation & Service Management
# ============================================================================

install_openclaw_local() {
    header "Installing OpenClaw"

    log "Installing openclaw via npm..."
    npm install -g openclaw@latest 2>/dev/null || sudo npm install -g openclaw@latest

    if command -v openclaw &>/dev/null; then
        log "OpenClaw installed: $(openclaw --version 2>/dev/null || echo 'OK')"
    else
        warn "openclaw command not found in PATH. You may need to restart your shell."
    fi
}

run_local_install() {
    header "Starting Local Installation"
    log "OS: ${OS_TYPE} | Distro: ${DISTRO} | Package Manager: ${PKG_MGR}"

    install_build_tools_local
    install_node_local
    install_python_local
    install_media_local

    if [[ "${ENABLE_VNC}" == "true" ]]; then
        install_browser_local
    else
        install_chromium_headless
    fi

    if [[ "${TOR_ENABLED}" == "true" ]]; then
        install_tor_local
    fi

    install_email_local
    install_openclaw_local
}

start_local_services() {
    header "Starting OpenClaw Services"

    # Configure SMTP
    if [[ -n "${SMTP_HOST:-}" ]]; then
        log "Configuring SMTP..."
        sudo tee /etc/msmtprc > /dev/null <<MSMTP
defaults
auth           on
tls            ${SMTP_TLS:-on}
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

account        default
host           ${SMTP_HOST}
port           ${SMTP_PORT:-587}
from           ${SMTP_FROM:-openclaw@localhost}
user           ${SMTP_USER:-}
password       ${SMTP_PASSWORD:-}
MSMTP
        sudo chmod 600 /etc/msmtprc
    fi

    # Start Tor
    if [[ "${TOR_ENABLED}" == "true" ]]; then
        log "Starting Tor..."
        if command -v systemctl &>/dev/null; then
            sudo systemctl start tor 2>/dev/null || sudo tor &
        elif command -v rc-service &>/dev/null; then
            sudo rc-service tor start 2>/dev/null || sudo tor &
        elif command -v brew &>/dev/null; then
            brew services start tor 2>/dev/null || tor &
        else
            sudo tor &
        fi
    fi

    # Start Xvfb + VNC (Linux only)
    if [[ "${ENABLE_VNC}" == "true" && "$OS_TYPE" != "macos" ]]; then
        log "Starting Xvfb on :99..."
        Xvfb :99 -screen 0 "${DISPLAY_RESOLUTION:-1920x1080x24}" -ac +extension GLX +render -noreset &
        export DISPLAY=:99
        sleep 1

        log "Starting Fluxbox..."
        fluxbox &
        sleep 1

        log "Starting x11vnc on port 5900..."
        if [[ -n "${VNC_PASSWORD:-}" ]]; then
            mkdir -p "$HOME/.vnc"
            x11vnc -storepasswd "${VNC_PASSWORD}" "$HOME/.vnc/passwd"
            x11vnc -display :99 -forever -shared -rfbport 5900 -rfbauth "$HOME/.vnc/passwd" &
        else
            x11vnc -display :99 -forever -shared -rfbport 5900 -nopw &
        fi
        sleep 1

        if [[ -d /opt/novnc ]]; then
            log "Starting noVNC on port 6080..."
            /opt/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 &
        fi
    fi

    # Source .env for OpenClaw
    if [[ -f "$ENV_FILE" ]]; then
        set -a
        # shellcheck source=/dev/null
        source "$ENV_FILE"
        set +a
    fi

    # Start OpenClaw gateway
    log "Starting OpenClaw gateway..."
    local bind="${OPENCLAW_GATEWAY_BIND:-lan}"
    local args="gateway --bind ${bind}"
    if [[ -n "${OPENCLAW_GATEWAY_TOKEN:-}" ]]; then
        args="${args} --token ${OPENCLAW_GATEWAY_TOKEN}"
    fi

    openclaw $args &
    OPENCLAW_PID=$!

    # Health check
    log "Waiting for gateway to become ready..."
    local retries=0
    while ! curl -sf http://localhost:18789 &>/dev/null; do
        retries=$((retries + 1))
        if (( retries >= 30 )); then
            warn "Gateway not responding yet. Check: openclaw status"
            break
        fi
        sleep 2
    done
    if (( retries < 30 )); then
        log "Gateway is responding!"
    fi
}

docker_build_and_run() {
    header "Building OpenClaw Docker Image"
    cd "$SCRIPT_DIR"

    log "Building image (this may take several minutes on first run)..."
    docker compose build --progress=plain

    header "Starting OpenClaw Container"
    docker compose up -d

    log "Waiting for OpenClaw gateway to become ready..."
    local retries=0
    while ! curl -sf http://localhost:18789 &>/dev/null; do
        retries=$((retries + 1))
        if (( retries >= 40 )); then
            warn "Gateway not responding yet. Check: docker compose logs -f"
            break
        fi
        sleep 3
    done
    if (( retries < 40 )); then
        log "Gateway is responding!"
    fi
}
