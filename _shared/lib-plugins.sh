#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - Service-Based Plugin & Skill Installer
# Installs only the plugins, skills, CLI tools, and system packages
# that match the user's selected services
# ============================================================================

OPENCLAW_SKILLS_DIR="${HOME}/.openclaw/workspace/skills"
OPENCLAW_PLUGINS_DIR="${HOME}/.openclaw/plugins"
OPENCLAW_SKILLS_REPO="https://github.com/OpenClaw/skills.git"

# ============================================================================
# Service Registry
# Each service maps to: description, npm packages, skills, CLI tools, sys deps
# ============================================================================

# All available service IDs (order matters for display)
ALL_SERVICE_IDS=(
    # -- Channels --
    telegram discord slack whatsapp webchat teams
    # -- Skills --
    browser cron exec file-system
    gmail-gog webhooks nano-pdf
    todoist trello obsidian blogwatcher
    whisper image-gen spotify openhue eightctl
    # -- Developer tools --
    github-cli
    # -- Core utilities --
    memory scheduler analytics logger
)

# Human-readable labels (parallel to ALL_SERVICE_IDS)
ALL_SERVICE_LABELS=(
    # -- Channels --
    "Telegram          - Telegram Bot channel"
    "Discord           - Discord Bot channel"
    "Slack             - Slack Bot channel"
    "WhatsApp          - WhatsApp via QR scan (needs VNC)"
    "WebChat           - Browser-based chat widget"
    "Teams             - Microsoft Teams channel"
    # -- Skills --
    "Browser           - Chromium headless/VNC browser automation"
    "Cron              - Scheduled task execution"
    "Exec              - Shell command execution (SSH, kubectl, docker)"
    "File System       - Local file read/write operations"
    "Gmail (gog)       - Gmail send/receive via gog CLI"
    "Webhooks          - Inbound/outbound HTTP webhooks"
    "nano-pdf          - PDF generation & parsing"
    "Todoist           - Todoist task management"
    "Trello            - Trello board integration"
    "Obsidian          - Obsidian vault note-taking"
    "Blogwatcher       - RSS/blog feed monitoring"
    "Whisper           - OpenAI Whisper speech-to-text"
    "Image Generation  - OpenAI DALL-E image generation"
    "Spotify           - Spotify playback & playlist control"
    "OpenHue           - Philips Hue smart lighting"
    "Eightctl / WHOOP  - WHOOP health/fitness data"
    # -- Developer tools --
    "GitHub CLI (gh)   - GitHub API, PRs, issues, actions"
    # -- Core utilities --
    "Memory            - Persistent conversation memory"
    "Scheduler         - Advanced job scheduling"
    "Analytics         - Usage analytics & tracking"
    "Logger            - Structured logging & audit trail"
)

# ============================================================================
# Service -> Package Mapping
# ============================================================================

# Get npm packages for a service
_service_npm_packages() {
    local svc="$1"
    case "$svc" in
        telegram)     echo "@openclaw/channel-telegram" ;;
        discord)      echo "@openclaw/channel-discord" ;;
        slack)        echo "@openclaw/channel-slack" ;;
        whatsapp)     echo "@openclaw/channel-whatsapp" ;;
        webchat)      echo "@openclaw/channel-webchat @openclaw/skill-webchat" ;;
        teams)        echo "@openclaw/channel-teams" ;;
        browser)      echo "@openclaw/skill-browser" ;;
        cron)         echo "@openclaw/skill-cron" ;;
        exec)         echo "@openclaw/skill-exec" ;;
        file-system)  echo "@openclaw/skill-file-system" ;;
        gmail-gog)    echo "@openclaw/skill-gmail-gog" ;;
        webhooks)     echo "@openclaw/skill-webhooks" ;;
        nano-pdf)     echo "@openclaw/skill-nano-pdf" ;;
        todoist)      echo "@openclaw/skill-todoist" ;;
        trello)       echo "@openclaw/skill-trello" ;;
        obsidian)     echo "@openclaw/skill-obsidian" ;;
        blogwatcher)  echo "@openclaw/skill-blogwatcher" ;;
        whisper)      echo "@openclaw/skill-openai-whisper" ;;
        image-gen)    echo "@openclaw/skill-openai-image-gen" ;;
        spotify)      echo "@openclaw/skill-spotify-player" ;;
        openhue)      echo "@openclaw/skill-openhue" ;;
        eightctl)     echo "@openclaw/skill-eightctl" ;;
        github-cli)   echo "" ;;  # CLI tool, not npm
        memory)       echo "@openclaw/plugin-memory" ;;
        scheduler)    echo "@openclaw/plugin-scheduler" ;;
        analytics)    echo "@openclaw/plugin-analytics" ;;
        logger)       echo "@openclaw/plugin-logger" ;;
    esac
}

# Get CLI tools to install for a service
_service_cli_tools() {
    local svc="$1"
    case "$svc" in
        gmail-gog)    echo "gog-cli" ;;
        whisper)      echo "openai-whisper yt-dlp" ;;
        github-cli)   echo "gh" ;;
        *)            echo "" ;;
    esac
}

# Check if a service requires Chromium / browser
_service_needs_browser() {
    local svc="$1"
    case "$svc" in
        browser|whatsapp) return 0 ;;
        *) return 1 ;;
    esac
}

# Check if a service requires VNC desktop
_service_needs_vnc() {
    local svc="$1"
    case "$svc" in
        whatsapp) return 0 ;;
        *) return 1 ;;
    esac
}

# ============================================================================
# Interactive Services Wizard
# ============================================================================

# Call with: wizard_services recommended_services_array
# Sets SELECTED_SERVICES global array with final choices
wizard_services() {
    local -n _recommended=$1

    header "Services & Integrations"
    echo -e "  Select which services to install for this use case."
    echo -e "  Recommended services are pre-selected based on the use case."
    echo -e "  You can add or remove any service.\n"

    # Build default selection state based on recommended list
    local -a defaults=()
    local count=${#ALL_SERVICE_IDS[@]}
    for i in "${!ALL_SERVICE_IDS[@]}"; do
        local svc="${ALL_SERVICE_IDS[$i]}"
        local found="false"
        for rec in "${_recommended[@]}"; do
            if [[ "$rec" == "$svc" ]]; then
                found="true"
                break
            fi
        done
        defaults+=("$found")
    done

    # Show interactive checklist
    checklist_select "Available Services" ALL_SERVICE_LABELS defaults

    # Build SELECTED_SERVICES from checklist results
    SELECTED_SERVICES=()
    for i in "${!ALL_SERVICE_IDS[@]}"; do
        if [[ "${CHECKLIST_RESULT[$i]}" == "true" ]]; then
            SELECTED_SERVICES+=("${ALL_SERVICE_IDS[$i]}")
        fi
    done

    # Show summary
    echo ""
    log "Selected services (${#SELECTED_SERVICES[@]}):"
    for svc in "${SELECTED_SERVICES[@]}"; do
        echo -e "    ${GREEN}+${NC} ${svc}"
    done
    echo ""
}

# ============================================================================
# Selective Installation (installs only what's selected)
# ============================================================================

install_selected_services() {
    if [[ ${#SELECTED_SERVICES[@]} -eq 0 ]]; then
        warn "No services selected. Skipping plugin installation."
        return
    fi

    header "Installing Selected Services (${#SELECTED_SERVICES[@]} services)"

    local npm_packages=()
    local cli_tools=()
    local needs_browser=false
    local needs_vnc=false
    local needs_gh=false
    local needs_gog=false
    local needs_whisper=false

    # Collect all packages and tools from selected services
    for svc in "${SELECTED_SERVICES[@]}"; do
        # Collect npm packages
        local pkgs
        pkgs=$(_service_npm_packages "$svc")
        if [[ -n "$pkgs" ]]; then
            for pkg in $pkgs; do
                # Avoid duplicates
                local dup=false
                for existing in "${npm_packages[@]}"; do
                    [[ "$existing" == "$pkg" ]] && dup=true && break
                done
                $dup || npm_packages+=("$pkg")
            done
        fi

        # Check for special requirements
        if _service_needs_browser "$svc"; then needs_browser=true; fi
        if _service_needs_vnc "$svc"; then needs_vnc=true; fi

        case "$svc" in
            github-cli) needs_gh=true ;;
            gmail-gog) needs_gog=true ;;
            whisper) needs_whisper=true ;;
        esac
    done

    # ---- Step 1: Install npm packages ----
    if [[ ${#npm_packages[@]} -gt 0 ]]; then
        log "Installing ${#npm_packages[@]} npm packages..."
        echo ""
        local installed=0
        local failed=0
        for pkg in "${npm_packages[@]}"; do
            echo -ne "  Installing ${CYAN}${pkg}${NC}... "
            if npm install -g "$pkg" &>/dev/null || sudo npm install -g "$pkg" &>/dev/null; then
                echo -e "${GREEN}OK${NC}"
                installed=$((installed + 1))
            else
                echo -e "${YELLOW}skipped${NC}"
                failed=$((failed + 1))
            fi
        done
        echo ""
        log "npm packages: ${installed} installed, ${failed} skipped"
    fi

    # ---- Step 2: Install CLI tools ----
    if $needs_gog; then
        _install_cli_gog
    fi

    if $needs_gh; then
        _install_cli_gh
    fi

    if $needs_whisper; then
        _install_cli_whisper
    fi

    # ---- Step 3: Install system dependencies if needed ----
    if $needs_browser; then
        if [[ "${ENABLE_VNC:-false}" == "true" ]] || $needs_vnc; then
            install_browser_local
        else
            install_chromium_headless
        fi
    fi

    # ---- Step 4: Clone community skills repo ----
    _install_community_skills

    # ---- Step 5: Always install core health-check + rate-limiter ----
    log "Installing core plugins (health-check, rate-limiter)..."
    npm install -g @openclaw/plugin-health-check @openclaw/plugin-rate-limiter &>/dev/null || \
    sudo npm install -g @openclaw/plugin-health-check @openclaw/plugin-rate-limiter &>/dev/null || true

    echo ""
    log "Service installation complete!"
    log "  Plugins: ${OPENCLAW_PLUGINS_DIR:-~/.openclaw/plugins}"
    log "  Skills:  ${OPENCLAW_SKILLS_DIR}"
}

# ============================================================================
# CLI Tool Installers
# ============================================================================

_install_cli_gog() {
    if command -v gog &>/dev/null; then
        log "gog CLI already installed"
        return
    fi
    log "Installing gog CLI (Gmail integration)..."
    npm install -g gog-cli 2>/dev/null || sudo npm install -g gog-cli 2>/dev/null || \
        warn "Could not install gog CLI. Install manually: npm install -g gog-cli"
}

_install_cli_gh() {
    if command -v gh &>/dev/null; then
        log "GitHub CLI already installed"
        return
    fi
    log "Installing GitHub CLI..."
    case "$PKG_MGR" in
        apt)
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
                sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
                sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt-get update -qq && sudo apt-get install -y gh
            ;;
        dnf) sudo dnf install -y gh ;;
        brew) brew install gh ;;
        pacman) sudo pacman -Sy --noconfirm github-cli ;;
        *) warn "Install gh CLI manually: https://cli.github.com" ;;
    esac
}

_install_cli_whisper() {
    log "Installing OpenAI Whisper & yt-dlp..."
    local pip_flags=""
    if python3 -c "import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)" 2>/dev/null; then
        pip_flags="--break-system-packages"
    fi
    pip3 install $pip_flags --no-cache-dir openai-whisper yt-dlp 2>/dev/null || \
    sudo pip3 install $pip_flags --no-cache-dir openai-whisper yt-dlp 2>/dev/null || \
        warn "Could not install Whisper. Install manually: pip3 install openai-whisper"
}

# ============================================================================
# Community Skills
# ============================================================================

_install_community_skills() {
    mkdir -p "${OPENCLAW_SKILLS_DIR}"

    if [[ -d "${OPENCLAW_SKILLS_DIR}/.community" ]]; then
        log "Updating community skills..."
        (cd "${OPENCLAW_SKILLS_DIR}/.community" && git pull --ff-only 2>/dev/null) || true
    else
        log "Cloning community skills repository..."
        git clone --depth 1 "${OPENCLAW_SKILLS_REPO}" "${OPENCLAW_SKILLS_DIR}/.community" 2>/dev/null || true
    fi

    # Copy matching skills for selected services
    if [[ -d "${OPENCLAW_SKILLS_DIR}/.community" ]]; then
        for svc in "${SELECTED_SERVICES[@]}"; do
            local skill_name="$svc"
            if [[ -d "${OPENCLAW_SKILLS_DIR}/.community/${skill_name}" ]]; then
                cp -r "${OPENCLAW_SKILLS_DIR}/.community/${skill_name}" "${OPENCLAW_SKILLS_DIR}/${skill_name}" 2>/dev/null || true
            fi
        done
    fi
}

# ============================================================================
# .env service variables
# Appends SELECTED_SERVICES to the .env file so Docker/entrypoint knows
# ============================================================================

append_services_to_env() {
    if [[ -f "$ENV_FILE" && ${#SELECTED_SERVICES[@]} -gt 0 ]]; then
        local svc_list
        svc_list=$(IFS=,; echo "${SELECTED_SERVICES[*]}")
        echo "" >> "$ENV_FILE"
        echo "# ---- Selected Services ----" >> "$ENV_FILE"
        echo "OPENCLAW_SERVICES=${svc_list}" >> "$ENV_FILE"
    fi
}

# ============================================================================
# Load services from .env (for --env-file non-interactive mode)
# ============================================================================

load_services_from_env() {
    if [[ -n "${OPENCLAW_SERVICES:-}" ]]; then
        IFS=',' read -ra SELECTED_SERVICES <<< "$OPENCLAW_SERVICES"
        log "Services loaded from env: ${#SELECTED_SERVICES[@]} services"
    fi
}
