#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - .env File Loader
# Load environment variables from a .env file (supports --env-file flag)
# ============================================================================

load_env_file() {
    local env_file="$1"

    if [[ ! -f "$env_file" ]]; then
        err "Environment file not found: ${env_file}"
        exit 1
    fi

    log "Loading configuration from: ${env_file}"

    # Read .env file, skip comments and blank lines
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        # Remove inline comments
        line="${line%%#*}"
        # Trim whitespace
        line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        [[ -z "$line" ]] && continue

        # Extract key=value
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            # Remove surrounding quotes if present
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"
            # Export the variable
            export "$key=$value"
            eval "${key}='${value}'"
        fi
    done < "$env_file"

    # Set defaults for any missing required variables
    : "${AI_PROVIDER:=grok}"
    : "${OPENCLAW_PRIMARY_MODEL:=grok-3}"
    : "${INSTALL_MODE:=docker}"
    : "${ENABLE_VNC:=true}"
    : "${TOR_ENABLED:=true}"
    : "${TOR_SOCKS_PORT:=9050}"
    : "${SMTP_PORT:=587}"
    : "${SMTP_TLS:=on}"
    : "${DISPLAY_RESOLUTION:=1920x1080x24}"
    : "${OPENCLAW_GATEWAY_BIND:=lan}"
    : "${WHATSAPP_ENABLED:=false}"

    # Generate gateway token if missing
    if [[ -z "${OPENCLAW_GATEWAY_TOKEN:-}" ]]; then
        OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32 2>/dev/null || head -c 64 /dev/urandom | od -A n -t x1 | tr -d ' \n')
        warn "No gateway token in env file. Auto-generated one."
    fi

    # Prompt for critical missing values
    if [[ -z "${XAI_API_KEY:-}" ]]; then
        warn "No XAI_API_KEY found in env file."
        if [[ -t 0 ]]; then
            prompt_secret XAI_API_KEY "Enter your xAI / Grok API key (or press Enter to skip)"
        fi
    fi

    log "Configuration loaded from env file"
}
