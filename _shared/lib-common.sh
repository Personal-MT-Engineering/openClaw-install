#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - Common Utilities
# Colors, logging, prompts, menu selection
# ============================================================================

# ---- Colors ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ---- Globals ----
ENV_FILE=""
ENV_FILE_INPUT=""
INSTALL_MODE=""   # "docker" or "local"

# Selected services (populated by wizard_services)
declare -a SELECTED_SERVICES=()

# ---- Logging ----
log()     { echo -e "${GREEN}[OpenClaw]${NC} $*"; }
warn()    { echo -e "${YELLOW}[OpenClaw]${NC} $*"; }
err()     { echo -e "${RED}[OpenClaw]${NC} $*" >&2; }
header()  { echo -e "\n${CYAN}${BOLD}═══ $* ═══${NC}\n"; }

# ---- Prompts ----
prompt() {
    local var_name="$1"
    local prompt_text="$2"
    local default="${3:-}"
    local input
    if [[ -n "$default" ]]; then
        echo -en "${BOLD}${prompt_text}${NC} [${default}]: "
    else
        echo -en "${BOLD}${prompt_text}${NC}: "
    fi
    read -r input
    eval "${var_name}='${input:-$default}'"
}

prompt_secret() {
    local var_name="$1"
    local prompt_text="$2"
    local input
    echo -en "${BOLD}${prompt_text}${NC}: "
    read -rs input
    echo ""
    eval "${var_name}='${input}'"
}

prompt_yesno() {
    local prompt_text="$1"
    local default="${2:-n}"
    local input
    if [[ "$default" == "y" ]]; then
        echo -en "${BOLD}${prompt_text}${NC} [Y/n]: "
    else
        echo -en "${BOLD}${prompt_text}${NC} [y/N]: "
    fi
    read -r input
    input="${input:-$default}"
    [[ "${input,,}" == "y" || "${input,,}" == "yes" ]]
}

menu_select() {
    local title="$1"
    shift
    local options=("$@")
    echo -e "\n${BOLD}${title}${NC}"
    for i in "${!options[@]}"; do
        echo -e "  ${CYAN}$((i+1)))${NC} ${options[$i]}"
    done
    local choice
    while true; do
        echo -en "\n${BOLD}Select [1-${#options[@]}]:${NC} "
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
            return $((choice - 1))
        fi
        echo -e "${RED}Invalid choice. Try again.${NC}"
    done
}

# ---- Interactive Checklist (multi-select with toggle) ----
# Usage: checklist_select "Title" labels_array selected_array
#   labels_array:   ("Browser automation" "Gmail integration" ...)
#   selected_array: ("true" "false" "true" ...)   # pre-selected state
# After return, CHECKLIST_RESULT contains ("true"/"false" ...) for each item
declare -a CHECKLIST_RESULT=()

checklist_select() {
    local title="$1"
    local -n _labels=$2
    local -n _defaults=$3
    local count=${#_labels[@]}

    # Copy defaults into working state
    local -a state=()
    for i in "${!_defaults[@]}"; do
        state+=("${_defaults[$i]}")
    done

    while true; do
        echo ""
        echo -e "${CYAN}${BOLD}${title}${NC}"
        echo -e "${BOLD}  Toggle a service by entering its number. Press Enter when done.${NC}"
        echo ""
        for i in "${!_labels[@]}"; do
            local marker
            if [[ "${state[$i]}" == "true" ]]; then
                marker="${GREEN}[x]${NC}"
            else
                marker="[ ]"
            fi
            printf "  ${CYAN}%2d)${NC} %b %s\n" "$((i + 1))" "$marker" "${_labels[$i]}"
        done

        echo ""
        echo -en "${BOLD}  Toggle [1-${count}], 'a' = select all, 'n' = select none, Enter = confirm:${NC} "
        local input
        read -r input

        # Empty input = done
        if [[ -z "$input" ]]; then
            break
        fi

        # Select all
        if [[ "$input" == "a" || "$input" == "A" ]]; then
            for i in "${!state[@]}"; do state[$i]="true"; done
            continue
        fi

        # Select none
        if [[ "$input" == "n" || "$input" == "N" ]]; then
            for i in "${!state[@]}"; do state[$i]="false"; done
            continue
        fi

        # Toggle single item
        if [[ "$input" =~ ^[0-9]+$ ]] && (( input >= 1 && input <= count )); then
            local idx=$((input - 1))
            if [[ "${state[$idx]}" == "true" ]]; then
                state[$idx]="false"
            else
                state[$idx]="true"
            fi
        else
            echo -e "  ${RED}Invalid input. Enter a number, 'a', 'n', or press Enter.${NC}"
        fi
    done

    # Write results
    CHECKLIST_RESULT=("${state[@]}")
}

# ---- CLI Argument Parsing ----
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --env-file)
                ENV_FILE_INPUT="$2"
                shift 2
                ;;
            --env-file=*)
                ENV_FILE_INPUT="${1#*=}"
                shift
                ;;
            --docker)
                INSTALL_MODE="docker"
                shift
                ;;
            --local)
                INSTALL_MODE="local"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
}

# ---- Installation Mode Selection ----
choose_install_mode() {
    if [[ -n "$INSTALL_MODE" ]]; then
        log "Installation mode: ${INSTALL_MODE} (from CLI flag)"
        return
    fi

    header "Installation Mode"

    echo -e "  ${BOLD}Docker${NC} - Runs OpenClaw in an isolated container."
    echo -e "           All dependencies are bundled. Easiest setup."
    echo ""
    echo -e "  ${BOLD}Local${NC}  - Installs OpenClaw and all dependencies directly"
    echo -e "           on this machine. More control, better performance."
    echo ""

    menu_select "How would you like to install OpenClaw?" \
        "Docker (Recommended - isolated, portable)" \
        "Local (bare-metal, installed natively)"
    local choice=$?

    case $choice in
        0) INSTALL_MODE="docker" ;;
        1) INSTALL_MODE="local" ;;
    esac

    log "Installation mode: ${INSTALL_MODE}"
}

# ---- Final Status ----
print_final_status() {
    local use_case_name="${1:-OpenClaw}"
    echo ""
    echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║       ${use_case_name} - Installation Complete       ║${NC}"
    echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}${BOLD}Mode:${NC} ${INSTALL_MODE^^}"
    echo ""
    echo -e "  ${GREEN}${BOLD}Access URLs:${NC}"
    echo -e "    Gateway:    ${BOLD}http://localhost:18789${NC}"
    echo -e "    Bridge:     ${BOLD}http://localhost:18790${NC}"

    if [[ "${ENABLE_VNC:-false}" == "true" ]]; then
        echo -e "    noVNC:      ${BOLD}http://localhost:6080${NC}"
        echo -e "    VNC:        ${BOLD}vnc://localhost:5900${NC}"
    fi

    echo ""
    echo -e "  ${GREEN}${BOLD}Useful Commands:${NC}"

    if [[ "$INSTALL_MODE" == "docker" ]]; then
        echo -e "    View logs:          ${BOLD}docker compose logs -f${NC}"
        echo -e "    Stop:               ${BOLD}docker compose down${NC}"
        echo -e "    Restart:            ${BOLD}docker compose restart${NC}"
        echo -e "    Shell access:       ${BOLD}docker exec -it openclaw bash${NC}"
    else
        echo -e "    OpenClaw status:    ${BOLD}openclaw status${NC}"
        echo -e "    Stop:               ${BOLD}kill \$(pgrep -f 'openclaw gateway')${NC}"
    fi

    echo ""
    echo -e "  ${GREEN}${BOLD}Configuration:${NC} ${ENV_FILE}"
    echo -e "  ${GREEN}${BOLD}Gateway Token:${NC} ${OPENCLAW_GATEWAY_TOKEN:-<see .env file>}"
    echo ""
    echo -e "  ${CYAN}Enjoy OpenClaw!${NC}"
    echo ""
}
