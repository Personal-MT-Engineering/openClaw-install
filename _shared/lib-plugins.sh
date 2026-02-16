#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - Plugin & Skill Downloader
# Downloads and installs all OpenClaw plugins, skills, and integrations
# to enhance bot capabilities for each use case
# ============================================================================

OPENCLAW_SKILLS_DIR="${HOME}/.openclaw/workspace/skills"
OPENCLAW_PLUGINS_DIR="${HOME}/.openclaw/plugins"
OPENCLAW_SKILLS_REPO="https://github.com/OpenClaw/skills.git"
OPENCLAW_PLUGINS_REPO="https://github.com/OpenClaw/plugins.git"

# ---- Master list of known OpenClaw skill packages (npm) ----
OPENCLAW_NPM_SKILLS=(
    "@openclaw/skill-browser"
    "@openclaw/skill-cron"
    "@openclaw/skill-exec"
    "@openclaw/skill-file-system"
    "@openclaw/skill-gmail-gog"
    "@openclaw/skill-webhooks"
    "@openclaw/skill-nano-pdf"
    "@openclaw/skill-todoist"
    "@openclaw/skill-trello"
    "@openclaw/skill-obsidian"
    "@openclaw/skill-blogwatcher"
    "@openclaw/skill-openai-whisper"
    "@openclaw/skill-openai-image-gen"
    "@openclaw/skill-spotify-player"
    "@openclaw/skill-openhue"
    "@openclaw/skill-eightctl"
    "@openclaw/skill-webchat"
)

# ---- Channel/platform plugins ----
OPENCLAW_CHANNEL_PLUGINS=(
    "@openclaw/channel-telegram"
    "@openclaw/channel-discord"
    "@openclaw/channel-slack"
    "@openclaw/channel-whatsapp"
    "@openclaw/channel-webchat"
    "@openclaw/channel-teams"
)

# ---- Utility plugins ----
OPENCLAW_UTILITY_PLUGINS=(
    "@openclaw/plugin-memory"
    "@openclaw/plugin-scheduler"
    "@openclaw/plugin-analytics"
    "@openclaw/plugin-rate-limiter"
    "@openclaw/plugin-logger"
    "@openclaw/plugin-backup"
    "@openclaw/plugin-health-check"
)

# ---- Install all OpenClaw npm skill packages ----
install_all_npm_skills() {
    header "Installing OpenClaw Skill Packages"

    local installed=0
    local failed=0

    for pkg in "${OPENCLAW_NPM_SKILLS[@]}"; do
        log "Installing skill: ${pkg}..."
        if npm install -g "${pkg}" 2>/dev/null || sudo npm install -g "${pkg}" 2>/dev/null; then
            installed=$((installed + 1))
        else
            warn "Could not install ${pkg} (may not be published yet)"
            failed=$((failed + 1))
        fi
    done

    log "Skills installed: ${installed} | Skipped: ${failed}"
}

# ---- Install all channel plugins ----
install_all_channel_plugins() {
    header "Installing OpenClaw Channel Plugins"

    local installed=0

    for pkg in "${OPENCLAW_CHANNEL_PLUGINS[@]}"; do
        log "Installing channel: ${pkg}..."
        if npm install -g "${pkg}" 2>/dev/null || sudo npm install -g "${pkg}" 2>/dev/null; then
            installed=$((installed + 1))
        else
            warn "Could not install ${pkg} (may not be published yet)"
        fi
    done

    log "Channel plugins installed: ${installed}"
}

# ---- Install utility plugins ----
install_all_utility_plugins() {
    header "Installing OpenClaw Utility Plugins"

    local installed=0

    for pkg in "${OPENCLAW_UTILITY_PLUGINS[@]}"; do
        log "Installing utility: ${pkg}..."
        if npm install -g "${pkg}" 2>/dev/null || sudo npm install -g "${pkg}" 2>/dev/null; then
            installed=$((installed + 1))
        else
            warn "Could not install ${pkg} (may not be published yet)"
        fi
    done

    log "Utility plugins installed: ${installed}"
}

# ---- Clone community skills repository ----
install_community_skills() {
    header "Installing Community Skills"

    mkdir -p "${OPENCLAW_SKILLS_DIR}"

    if [[ -d "${OPENCLAW_SKILLS_DIR}/.community" ]]; then
        log "Updating community skills..."
        cd "${OPENCLAW_SKILLS_DIR}/.community"
        git pull --ff-only 2>/dev/null || warn "Could not update community skills"
    else
        log "Cloning community skills repository..."
        git clone --depth 1 "${OPENCLAW_SKILLS_REPO}" "${OPENCLAW_SKILLS_DIR}/.community" 2>/dev/null || \
            warn "Community skills repo not available yet"
    fi

    # Copy skills to the active skills directory
    if [[ -d "${OPENCLAW_SKILLS_DIR}/.community" ]]; then
        for skill_dir in "${OPENCLAW_SKILLS_DIR}/.community"/*/; do
            if [[ -f "${skill_dir}/SKILL.md" ]]; then
                local skill_name
                skill_name="$(basename "${skill_dir}")"
                if [[ ! -d "${OPENCLAW_SKILLS_DIR}/${skill_name}" ]]; then
                    cp -r "${skill_dir}" "${OPENCLAW_SKILLS_DIR}/${skill_name}"
                    log "  Installed community skill: ${skill_name}"
                fi
            fi
        done
    fi
}

# ---- Clone plugins repository ----
install_community_plugins() {
    header "Installing Community Plugins"

    mkdir -p "${OPENCLAW_PLUGINS_DIR}"

    if [[ -d "${OPENCLAW_PLUGINS_DIR}/.community" ]]; then
        log "Updating community plugins..."
        cd "${OPENCLAW_PLUGINS_DIR}/.community"
        git pull --ff-only 2>/dev/null || warn "Could not update community plugins"
    else
        log "Cloning community plugins repository..."
        git clone --depth 1 "${OPENCLAW_PLUGINS_REPO}" "${OPENCLAW_PLUGINS_DIR}/.community" 2>/dev/null || \
            warn "Community plugins repo not available yet"
    fi
}

# ---- Install specific skills by name (for use-case-specific installs) ----
install_skills_by_name() {
    local skills=("$@")
    mkdir -p "${OPENCLAW_SKILLS_DIR}"

    for skill in "${skills[@]}"; do
        log "Installing skill: ${skill}..."

        # Try npm package first
        npm install -g "@openclaw/skill-${skill}" 2>/dev/null || \
        sudo npm install -g "@openclaw/skill-${skill}" 2>/dev/null || true

        # Try community repo
        if [[ -d "${OPENCLAW_SKILLS_DIR}/.community/${skill}" ]]; then
            cp -r "${OPENCLAW_SKILLS_DIR}/.community/${skill}" "${OPENCLAW_SKILLS_DIR}/${skill}" 2>/dev/null || true
            log "  Installed from community repo: ${skill}"
        fi
    done
}

# ---- Install specific plugins by name ----
install_plugins_by_name() {
    local plugins=("$@")

    for plugin in "${plugins[@]}"; do
        log "Installing plugin: ${plugin}..."
        npm install -g "@openclaw/${plugin}" 2>/dev/null || \
        sudo npm install -g "@openclaw/${plugin}" 2>/dev/null || \
        warn "Could not install ${plugin}"
    done
}

# ---- Install third-party CLI tools used by skills ----
install_skill_cli_tools() {
    header "Installing Skill CLI Tools"

    # gog CLI (Gmail integration)
    if ! command -v gog &>/dev/null; then
        log "Installing gog CLI (Gmail)..."
        npm install -g gog-cli 2>/dev/null || sudo npm install -g gog-cli 2>/dev/null || true
    fi

    # GitHub CLI
    if ! command -v gh &>/dev/null; then
        log "Installing GitHub CLI..."
        case "$PKG_MGR" in
            apt)
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                sudo apt-get update -qq && sudo apt-get install -y gh
                ;;
            dnf) sudo dnf install -y gh ;;
            brew) brew install gh ;;
            pacman) sudo pacman -Sy --noconfirm github-cli ;;
            *) warn "Install gh CLI manually: https://cli.github.com" ;;
        esac
    fi

    # yt-dlp (media download)
    if ! command -v yt-dlp &>/dev/null; then
        log "Installing yt-dlp..."
        pip3 install yt-dlp 2>/dev/null || sudo pip3 install yt-dlp 2>/dev/null || true
    fi

    # whisper (speech-to-text)
    if ! command -v whisper &>/dev/null; then
        log "Installing OpenAI Whisper..."
        pip3 install openai-whisper 2>/dev/null || sudo pip3 install openai-whisper 2>/dev/null || true
    fi

    log "Skill CLI tools installed"
}

# ---- Master function: install ALL plugins and skills ----
install_all_plugins_and_skills() {
    header "Downloading All OpenClaw Plugins & Skills"
    log "This will download and install all available plugins, skills,"
    log "and integrations to maximize your bot's capabilities."
    echo ""

    install_all_npm_skills
    install_all_channel_plugins
    install_all_utility_plugins
    install_community_skills
    install_community_plugins
    install_skill_cli_tools

    echo ""
    log "All plugins and skills have been installed!"
    log "Skills directory: ${OPENCLAW_SKILLS_DIR}"
    log "Plugins directory: ${OPENCLAW_PLUGINS_DIR}"
}

# ---- Install plugins matching a use case's needs ----
# Call with: install_use_case_plugins browser cron gmail webhooks
install_use_case_plugins() {
    local integrations=("$@")
    header "Installing Use-Case Plugins & Skills"

    # Always install core utilities
    install_plugins_by_name "plugin-memory" "plugin-scheduler" "plugin-logger" "plugin-health-check"

    # Install based on integration keywords
    for integration in "${integrations[@]}"; do
        case "$integration" in
            browser)
                install_skills_by_name "browser"
                ;;
            cron|scheduler)
                install_skills_by_name "cron"
                ;;
            gmail|gog|email)
                install_skills_by_name "gmail-gog"
                install_skill_cli_tools_gog
                ;;
            webhooks|webhook)
                install_skills_by_name "webhooks"
                ;;
            nano-pdf|pdf)
                install_skills_by_name "nano-pdf"
                ;;
            todoist)
                install_skills_by_name "todoist"
                ;;
            trello)
                install_skills_by_name "trello"
                ;;
            obsidian)
                install_skills_by_name "obsidian"
                ;;
            blogwatcher|rss)
                install_skills_by_name "blogwatcher"
                ;;
            whisper|speech)
                install_skills_by_name "openai-whisper"
                ;;
            image-gen|dalle)
                install_skills_by_name "openai-image-gen"
                ;;
            spotify|music)
                install_skills_by_name "spotify-player"
                ;;
            openhue|hue)
                install_skills_by_name "openhue"
                ;;
            eightctl|whoop)
                install_skills_by_name "eightctl"
                ;;
            webchat)
                install_skills_by_name "webchat"
                install_plugins_by_name "channel-webchat"
                ;;
            telegram)
                install_plugins_by_name "channel-telegram"
                ;;
            discord)
                install_plugins_by_name "channel-discord"
                ;;
            slack)
                install_plugins_by_name "channel-slack"
                ;;
            whatsapp)
                install_plugins_by_name "channel-whatsapp"
                ;;
            teams)
                install_plugins_by_name "channel-teams"
                ;;
            exec|ssh)
                install_skills_by_name "exec"
                ;;
            filesystem|file-system)
                install_skills_by_name "file-system"
                ;;
            github|gh)
                install_skill_cli_tools_gh
                ;;
        esac
    done

    log "Use-case plugins and skills installed"
}

# ---- Helper: install just gog CLI ----
install_skill_cli_tools_gog() {
    if ! command -v gog &>/dev/null; then
        log "Installing gog CLI (Gmail)..."
        npm install -g gog-cli 2>/dev/null || sudo npm install -g gog-cli 2>/dev/null || true
    fi
}

# ---- Helper: install just gh CLI ----
install_skill_cli_tools_gh() {
    if ! command -v gh &>/dev/null; then
        log "Installing GitHub CLI..."
        case "$PKG_MGR" in
            apt)
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                sudo apt-get update -qq && sudo apt-get install -y gh
                ;;
            dnf) sudo dnf install -y gh ;;
            brew) brew install gh ;;
            pacman) sudo pacman -Sy --noconfirm github-cli ;;
            *) warn "Install gh CLI manually: https://cli.github.com" ;;
        esac
    fi
}
