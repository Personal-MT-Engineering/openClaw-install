#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - Health Check Registration
# Registers the OpenClaw instance with the central health monitoring server
# ============================================================================

# Default health check server URL (can be overridden via env)
HEALTHCHECK_SERVER="${HEALTHCHECK_SERVER_URL:-}"

# ---- Wizard: Ask for health check server URL ----
wizard_healthcheck() {
    header "Health Check Monitoring"
    echo -e "  Register this OpenClaw instance with a central health monitoring dashboard."
    echo -e "  This allows continuous ping-based monitoring and uptime reporting.\n"

    if prompt_yesno "Register with a health check server?" "y"; then
        HEALTHCHECK_SERVER=$(prompt "Health Check Server URL" "${HEALTHCHECK_SERVER:-http://localhost:4400}")
    else
        HEALTHCHECK_SERVER=""
    fi
}

# ---- Register with health check server ----
register_with_healthcheck() {
    if [[ -z "${HEALTHCHECK_SERVER}" ]]; then
        return 0
    fi

    local server_url="${HEALTHCHECK_SERVER%/}"
    local gateway_port="${OPENCLAW_GATEWAY_PORT:-18789}"
    local local_ip

    # Try to detect the local IP
    if command -v hostname &>/dev/null; then
        local_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    if [[ -z "$local_ip" ]]; then
        local_ip=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')
    fi
    if [[ -z "$local_ip" ]]; then
        local_ip="localhost"
    fi

    local instance_url="http://${local_ip}:${gateway_port}"

    log "Registering with health check server at ${server_url}..."

    local payload
    payload=$(cat <<EOJSON
{
  "name": "${USE_CASE_TITLE:-OpenClaw Instance}",
  "url": "${instance_url}",
  "use_case": "${USE_CASE_TITLE:-}",
  "use_case_id": "${USE_CASE_NAME:-}",
  "description": "Auto-registered from installer"
}
EOJSON
)

    if command -v curl &>/dev/null; then
        if curl -s -X POST "${server_url}/api/register" \
            -H "Content-Type: application/json" \
            -d "$payload" \
            --connect-timeout 5 \
            --max-time 10 &>/dev/null; then
            log "Successfully registered with health check server"
        else
            warn "Could not register with health check server at ${server_url}"
            warn "You can register manually later via the dashboard"
        fi
    elif command -v wget &>/dev/null; then
        if echo "$payload" | wget -q -O /dev/null --post-data=- \
            --header="Content-Type: application/json" \
            "${server_url}/api/register" 2>/dev/null; then
            log "Successfully registered with health check server"
        else
            warn "Could not register with health check server at ${server_url}"
        fi
    else
        warn "Neither curl nor wget found. Cannot register with health check server."
        warn "Register manually at ${server_url}"
    fi
}

# ---- Add health endpoint to .env ----
append_healthcheck_to_env() {
    if [[ -f "$ENV_FILE" && -n "${HEALTHCHECK_SERVER}" ]]; then
        echo "" >> "$ENV_FILE"
        echo "# ---- Health Check Monitoring ----" >> "$ENV_FILE"
        echo "HEALTHCHECK_SERVER_URL=${HEALTHCHECK_SERVER}" >> "$ENV_FILE"
    fi
}

# ---- Ensure the OpenClaw gateway exposes /health ----
# The @openclaw/plugin-health-check npm package (installed by lib-plugins.sh)
# provides the /health endpoint on the gateway automatically.
# This function is a no-op but documents the dependency.
ensure_health_endpoint() {
    log "Health endpoint will be available at http://localhost:${OPENCLAW_GATEWAY_PORT:-18789}/health"
}
