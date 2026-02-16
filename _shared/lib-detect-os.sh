#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - OS Detection
# Detects OS type, distribution, and package manager
# ============================================================================

OS_TYPE=""        # "linux", "macos", "wsl", "freebsd"
DISTRO=""         # debian, ubuntu, fedora, arch, alpine, opensuse-leap, etc.
PKG_MGR=""        # apt, dnf, yum, pacman, zypper, apk, brew, pkg, etc.

detect_os() {
    header "Detecting Operating System"

    local uname_s
    uname_s="$(uname -s)"

    if [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then
        OS_TYPE="wsl"
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            DISTRO="${ID}"
        else
            DISTRO="ubuntu"
        fi
        log "Detected: WSL (${DISTRO})"
    elif [[ "$uname_s" == "Darwin" ]]; then
        OS_TYPE="macos"
        DISTRO="macos"
        PKG_MGR="brew"
        log "Detected: macOS $(sw_vers -productVersion 2>/dev/null || echo '')"
    elif [[ "$uname_s" == "FreeBSD" ]]; then
        OS_TYPE="freebsd"
        DISTRO="freebsd"
        PKG_MGR="pkg"
        log "Detected: FreeBSD $(freebsd-version 2>/dev/null || echo '')"
    elif [[ "$uname_s" == "Linux" ]]; then
        OS_TYPE="linux"
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            DISTRO="${ID}"
            log "Detected: Linux (${PRETTY_NAME:-$ID})"
        else
            DISTRO="unknown"
            log "Detected: Linux (unknown distribution)"
        fi
    else
        err "Unsupported operating system: ${uname_s}"
        exit 1
    fi

    # Determine package manager for Linux/WSL
    if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
        case "$DISTRO" in
            ubuntu|debian|linuxmint|pop|elementary|zorin|kali|raspbian)
                PKG_MGR="apt" ;;
            fedora)
                PKG_MGR="dnf" ;;
            centos|rhel|rocky|almalinux|ol)
                if command -v dnf &>/dev/null; then PKG_MGR="dnf"; else PKG_MGR="yum"; fi ;;
            arch|manjaro|endeavouros|garuda|artix)
                PKG_MGR="pacman" ;;
            opensuse*|sles)
                PKG_MGR="zypper" ;;
            alpine)
                PKG_MGR="apk" ;;
            gentoo)
                PKG_MGR="emerge" ;;
            void)
                PKG_MGR="xbps" ;;
            nixos)
                PKG_MGR="nix" ;;
            *)
                if command -v apt-get &>/dev/null; then PKG_MGR="apt"
                elif command -v dnf &>/dev/null; then PKG_MGR="dnf"
                elif command -v yum &>/dev/null; then PKG_MGR="yum"
                elif command -v pacman &>/dev/null; then PKG_MGR="pacman"
                elif command -v zypper &>/dev/null; then PKG_MGR="zypper"
                elif command -v apk &>/dev/null; then PKG_MGR="apk"
                else PKG_MGR="unknown"
                fi
                ;;
        esac
        log "Package manager: ${PKG_MGR}"
    fi
}
