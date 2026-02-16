#!/usr/bin/env bash
set -euo pipefail

# ---- Colors ----
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
log() { echo -e "${GREEN}[OpenClaw]${NC} $*"; }
warn() { echo -e "${YELLOW}[OpenClaw]${NC} $*"; }

# ---- Configure SMTP ----
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

# ---- Start Tor ----
if [[ "${TOR_ENABLED:-true}" == "true" ]]; then
    log "Starting Tor..."
    sudo tor &
    sleep 2
fi

# ---- Start Xvfb + VNC ----
if [[ "${ENABLE_VNC:-true}" == "true" ]]; then
    log "Starting Xvfb on :99..."
    Xvfb :99 -screen 0 "${DISPLAY_RESOLUTION:-1920x1080x24}" -ac +extension GLX +render -noreset &
    sleep 1

    log "Starting Fluxbox..."
    fluxbox &
    sleep 1

    log "Starting x11vnc on port 5900..."
    if [[ -n "${VNC_PASSWORD:-}" ]]; then
        mkdir -p /home/node/.vnc
        x11vnc -storepasswd "${VNC_PASSWORD}" /home/node/.vnc/passwd
        x11vnc -display :99 -forever -shared -rfbport 5900 -rfbauth /home/node/.vnc/passwd &
    else
        x11vnc -display :99 -forever -shared -rfbport 5900 -nopw &
    fi
    sleep 1

    if [[ -d /opt/novnc ]]; then
        log "Starting noVNC on port 6080..."
        /opt/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 &
    fi
fi

# ---- Copy skills if present ----
if [[ -d /opt/openclaw-skills ]]; then
    log "Installing use-case skills..."
    mkdir -p /home/node/.openclaw/workspace/skills
    cp -r /opt/openclaw-skills/* /home/node/.openclaw/workspace/skills/ 2>/dev/null || true
    chown -R node:node /home/node/.openclaw/workspace/skills
fi

# ---- Apply config overlay if present ----
if [[ -f /opt/openclaw-config.json ]]; then
    log "Applying use-case configuration overlay..."
    mkdir -p /home/node/.openclaw
    if [[ -f /home/node/.openclaw/openclaw.json ]]; then
        # Merge configs using jq
        jq -s '.[0] * .[1]' /home/node/.openclaw/openclaw.json /opt/openclaw-config.json > /tmp/merged-config.json
        mv /tmp/merged-config.json /home/node/.openclaw/openclaw.json
    else
        cp /opt/openclaw-config.json /home/node/.openclaw/openclaw.json
    fi
    chown node:node /home/node/.openclaw/openclaw.json
fi

# ---- Start OpenClaw Gateway ----
log "Starting OpenClaw gateway..."
BIND="${OPENCLAW_GATEWAY_BIND:-lan}"
ARGS="gateway --bind ${BIND}"
if [[ -n "${OPENCLAW_GATEWAY_TOKEN:-}" ]]; then
    ARGS="${ARGS} --token ${OPENCLAW_GATEWAY_TOKEN}"
fi

exec su -s /bin/bash node -c "openclaw ${ARGS}"
