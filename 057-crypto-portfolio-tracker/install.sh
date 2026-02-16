#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_DIR="${SCRIPT_DIR}/../_shared"

# Source shared libraries
source "${SHARED_DIR}/lib-common.sh"
source "${SHARED_DIR}/lib-detect-os.sh"
source "${SHARED_DIR}/lib-docker.sh"
source "${SHARED_DIR}/lib-packages.sh"
source "${SHARED_DIR}/lib-node.sh"
source "${SHARED_DIR}/lib-python.sh"
source "${SHARED_DIR}/lib-browser.sh"
source "${SHARED_DIR}/lib-media.sh"
source "${SHARED_DIR}/lib-email.sh"
source "${SHARED_DIR}/lib-tor.sh"
source "${SHARED_DIR}/lib-openclaw.sh"
source "${SHARED_DIR}/lib-wizard.sh"
source "${SHARED_DIR}/lib-env-generator.sh"
source "${SHARED_DIR}/lib-env-loader.sh"
source "${SHARED_DIR}/lib-plugins.sh"

USE_CASE_NAME="057-crypto-portfolio-tracker"
USE_CASE_TITLE="Crypto Portfolio Tracker"

# Services recommended for this use case (pre-selected in wizard)
RECOMMENDED_SERVICES=(
    "browser"
    "cron"
    "telegram"
    "whatsapp"
    "file-system"
    "memory"
    "logger"
)

# ---- Use-case-specific wizard ----
wizard_use_case() {
    header "Use Case: ${USE_CASE_TITLE}"
    log "Configuring use-case-specific settings..."
    # Additional use-case prompts can be added here
}

# ---- Install use-case skills ----
install_use_case_skills() {
    local skills_dir="${HOME}/.openclaw/workspace/skills"
    mkdir -p "${skills_dir}"
    cp -r "${SCRIPT_DIR}/skills/"* "${skills_dir}/" 2>/dev/null || true
    log "Use-case skills installed"
}

# ---- Apply use-case config overlay ----
apply_use_case_config() {
    local config_dir="${HOME}/.openclaw"
    mkdir -p "${config_dir}"
    if [[ -f "${SCRIPT_DIR}/openclaw.config.json" ]]; then
        if [[ -f "${config_dir}/openclaw.json" ]]; then
            if command -v jq &>/dev/null; then
                jq -s '.[0] * .[1]' "${config_dir}/openclaw.json" "${SCRIPT_DIR}/openclaw.config.json" > /tmp/merged-config.json
                mv /tmp/merged-config.json "${config_dir}/openclaw.json"
            else
                cp "${SCRIPT_DIR}/openclaw.config.json" "${config_dir}/openclaw.json"
            fi
        else
            cp "${SCRIPT_DIR}/openclaw.config.json" "${config_dir}/openclaw.json"
        fi
        log "Configuration overlay applied"
    fi
}

# ---- Main ----
main() {
    echo ""
    echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║       OpenClaw - ${USE_CASE_TITLE}${NC}"
    echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""

    parse_args "$@"
    ENV_FILE="${SCRIPT_DIR}/.env"

    detect_os
    choose_install_mode

    if [[ -n "${ENV_FILE_INPUT:-}" ]]; then
        load_env_file "${ENV_FILE_INPUT}"
        load_services_from_env
        # If no OPENCLAW_SERVICES in env, use recommended defaults
        if [[ ${#SELECTED_SERVICES[@]} -eq 0 ]]; then
            SELECTED_SERVICES=("${RECOMMENDED_SERVICES[@]}")
        fi
    else
        wizard_ai_provider
        wizard_channels
        wizard_smtp
        wizard_vnc
        wizard_tor
        wizard_gateway
        wizard_use_case
        wizard_services RECOMMENDED_SERVICES
    fi

    generate_env
    append_services_to_env

    if [[ "$INSTALL_MODE" == "docker" ]]; then
        ensure_docker
        docker_build_and_run
    else
        run_local_install
        install_selected_services
        install_use_case_skills
        apply_use_case_config
        start_local_services
    fi

    print_final_status "${USE_CASE_TITLE}"
}

main "$@"
