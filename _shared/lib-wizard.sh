#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - Interactive Configuration Wizard
# AI provider, channels, SMTP, VNC, Tor, gateway configuration
# ============================================================================

wizard_ai_provider() {
    header "AI Provider Configuration"

    AI_PROVIDER="grok"
    OPENCLAW_PRIMARY_MODEL="grok-3"
    XAI_API_KEY=""
    ANTHROPIC_API_KEY=""
    OPENAI_API_KEY=""
    GOOGLE_GEMINI_API_KEY=""
    OPENROUTER_API_KEY=""
    MISTRAL_API_KEY=""
    GROQ_API_KEY=""
    PERPLEXITY_API_KEY=""
    DEEPSEEK_API_KEY=""
    COHERE_API_KEY=""
    OLLAMA_BASE_URL=""

    echo -e "  OpenClaw uses ${BOLD}Grok (xAI)${NC} as the default AI provider."
    echo -e "  You can also add API keys for other providers to make them"
    echo -e "  available for multi-model use.\n"

    prompt_secret XAI_API_KEY "Enter your xAI / Grok API key"
    if [[ -z "$XAI_API_KEY" ]]; then
        warn "No xAI API key provided. You can add it later in the .env file."
    fi

    echo ""
    echo -e "  ${BOLD}Optional:${NC} Add API keys for additional providers."
    echo -e "  Press Enter to skip any you don't need.\n"

    if prompt_yesno "Add additional AI provider keys?"; then
        echo ""
        prompt_secret ANTHROPIC_API_KEY "  Anthropic (Claude) API key"
        prompt_secret OPENAI_API_KEY "  OpenAI (ChatGPT) API key"
        prompt_secret GOOGLE_GEMINI_API_KEY "  Google Gemini API key"
        prompt_secret OPENROUTER_API_KEY "  OpenRouter API key"
        prompt_secret MISTRAL_API_KEY "  Mistral API key"
        prompt_secret GROQ_API_KEY "  Groq API key"
        prompt_secret PERPLEXITY_API_KEY "  Perplexity API key"
        prompt_secret DEEPSEEK_API_KEY "  DeepSeek API key"
        prompt_secret COHERE_API_KEY "  Cohere API key"

        if prompt_yesno "  Connect a local Ollama instance?"; then
            if [[ "$INSTALL_MODE" == "docker" ]]; then
                prompt OLLAMA_BASE_URL "  Ollama URL" "http://host.docker.internal:11434"
            else
                prompt OLLAMA_BASE_URL "  Ollama URL" "http://localhost:11434"
            fi
        fi
    fi

    local key_count=0
    [[ -n "$XAI_API_KEY" ]] && key_count=$((key_count + 1))
    [[ -n "$ANTHROPIC_API_KEY" ]] && key_count=$((key_count + 1))
    [[ -n "$OPENAI_API_KEY" ]] && key_count=$((key_count + 1))
    [[ -n "$GOOGLE_GEMINI_API_KEY" ]] && key_count=$((key_count + 1))
    [[ -n "$OPENROUTER_API_KEY" ]] && key_count=$((key_count + 1))
    [[ -n "$MISTRAL_API_KEY" ]] && key_count=$((key_count + 1))
    [[ -n "$GROQ_API_KEY" ]] && key_count=$((key_count + 1))
    [[ -n "$PERPLEXITY_API_KEY" ]] && key_count=$((key_count + 1))
    [[ -n "$DEEPSEEK_API_KEY" ]] && key_count=$((key_count + 1))
    [[ -n "$COHERE_API_KEY" ]] && key_count=$((key_count + 1))

    log "Default provider: Grok (xAI) | Model: ${OPENCLAW_PRIMARY_MODEL}"
    log "API keys configured: ${key_count}"
}

wizard_channels() {
    header "Channel Configuration"
    echo -e "Select which messaging platforms to connect.\n"

    TELEGRAM_BOT_TOKEN=""
    if prompt_yesno "Enable Telegram?"; then
        prompt_secret TELEGRAM_BOT_TOKEN "Enter Telegram Bot Token (from @BotFather)"
        log "Telegram: enabled"
    fi

    DISCORD_BOT_TOKEN=""
    if prompt_yesno "Enable Discord?"; then
        prompt_secret DISCORD_BOT_TOKEN "Enter Discord Bot Token"
        log "Discord: enabled"
    fi

    SLACK_BOT_TOKEN=""
    SLACK_APP_TOKEN=""
    if prompt_yesno "Enable Slack?"; then
        prompt_secret SLACK_BOT_TOKEN "Enter Slack Bot Token (xoxb-...)"
        prompt_secret SLACK_APP_TOKEN "Enter Slack App Token (xapp-...)"
        log "Slack: enabled"
    fi

    WHATSAPP_ENABLED="false"
    if prompt_yesno "Enable WhatsApp? (requires QR code scan via VNC desktop)"; then
        WHATSAPP_ENABLED="true"
        log "WhatsApp: enabled (will need QR scan after startup)"
    fi
}

wizard_smtp() {
    header "Email / SMTP Configuration (Optional)"
    SMTP_HOST=""
    SMTP_PORT="587"
    SMTP_USER=""
    SMTP_PASSWORD=""
    SMTP_FROM="openclaw@localhost"
    SMTP_TLS="on"

    if prompt_yesno "Configure SMTP for sending emails?"; then
        prompt SMTP_HOST "SMTP host (e.g., smtp.gmail.com)"
        prompt SMTP_PORT "SMTP port" "587"
        prompt SMTP_USER "SMTP username"
        prompt_secret SMTP_PASSWORD "SMTP password"
        prompt SMTP_FROM "From address" "${SMTP_USER}"
        prompt SMTP_TLS "Enable TLS (on/off)" "on"
        log "SMTP configured: ${SMTP_HOST}:${SMTP_PORT}"
    else
        log "SMTP: skipped"
    fi
}

wizard_vnc() {
    header "Desktop / VNC Configuration"

    if [[ "$OS_TYPE" == "macos" && "$INSTALL_MODE" == "local" ]]; then
        echo -e "On macOS, the native display is used. VNC/Xvfb is not needed.\n"
        ENABLE_VNC="false"
        VNC_PASSWORD=""
        DISPLAY_RESOLUTION="1920x1080x24"
        log "VNC: not applicable (macOS native display)"
        return
    fi

    echo -e "noVNC provides a web-based virtual desktop for browser automation,"
    echo -e "screenshots, and WhatsApp QR code scanning.\n"

    if prompt_yesno "Enable noVNC web desktop?" "y"; then
        ENABLE_VNC="true"
        prompt DISPLAY_RESOLUTION "Display resolution" "1920x1080x24"
        prompt_secret VNC_PASSWORD "VNC password (leave empty for no password)"
        log "VNC: enabled (${DISPLAY_RESOLUTION})"
    else
        ENABLE_VNC="false"
        VNC_PASSWORD=""
        DISPLAY_RESOLUTION="1920x1080x24"
        log "VNC: disabled (screenshots still available)"
    fi
}

wizard_tor() {
    header "Tor Configuration"
    echo -e "Tor provides anonymous network routing for privacy-sensitive operations.\n"

    if prompt_yesno "Enable Tor?" "y"; then
        TOR_ENABLED="true"
        TOR_SOCKS_PORT="9050"
        log "Tor: enabled (SOCKS port ${TOR_SOCKS_PORT})"
    else
        TOR_ENABLED="false"
        TOR_SOCKS_PORT="9050"
        log "Tor: disabled"
    fi
}

wizard_gateway() {
    header "Gateway Configuration"
    OPENCLAW_GATEWAY_TOKEN=""
    OPENCLAW_GATEWAY_BIND="lan"

    echo -e "The gateway token secures access to your OpenClaw instance.\n"
    prompt OPENCLAW_GATEWAY_TOKEN "Gateway token (leave empty to auto-generate)" ""
    if [[ -z "$OPENCLAW_GATEWAY_TOKEN" ]]; then
        OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32 2>/dev/null || head -c 64 /dev/urandom | od -A n -t x1 | tr -d ' \n')
        log "Auto-generated gateway token"
    fi
    prompt OPENCLAW_GATEWAY_BIND "Gateway bind mode (lan/localhost)" "lan"
}
