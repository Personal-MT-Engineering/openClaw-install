#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - Package Management
# Cross-platform package installation and name mapping
# ============================================================================

pkg_install() {
    local packages=("$@")
    log "Installing: ${packages[*]}"
    case "$PKG_MGR" in
        apt)
            sudo apt-get update -qq
            sudo apt-get install -y "${packages[@]}"
            ;;
        dnf)
            sudo dnf install -y "${packages[@]}"
            ;;
        yum)
            sudo yum install -y "${packages[@]}"
            ;;
        pacman)
            sudo pacman -Sy --noconfirm "${packages[@]}"
            ;;
        zypper)
            sudo zypper install -y "${packages[@]}"
            ;;
        apk)
            sudo apk add "${packages[@]}"
            ;;
        emerge)
            sudo emerge --ask=n "${packages[@]}"
            ;;
        xbps)
            sudo xbps-install -Sy "${packages[@]}"
            ;;
        nix)
            for p in "${packages[@]}"; do
                nix-env -iA "nixos.${p}" 2>/dev/null || nix-env -iA "nixpkgs.${p}" 2>/dev/null || warn "Could not install ${p} via nix"
            done
            ;;
        brew)
            brew install "${packages[@]}"
            ;;
        pkg)
            sudo pkg install -y "${packages[@]}"
            ;;
        *)
            err "No supported package manager found. Install manually: ${packages[*]}"
            return 1
            ;;
    esac
}

pkg_name() {
    local generic="$1"
    case "$generic" in
        python3)
            case "$PKG_MGR" in
                brew) echo "python@3" ;;
                pacman) echo "python" ;;
                apk) echo "python3" ;;
                *) echo "python3" ;;
            esac ;;
        python3-pip)
            case "$PKG_MGR" in
                brew) echo "" ;;
                pacman) echo "python-pip" ;;
                apk) echo "py3-pip" ;;
                zypper) echo "python3-pip" ;;
                *) echo "python3-pip" ;;
            esac ;;
        python3-venv)
            case "$PKG_MGR" in
                apt) echo "python3-venv" ;;
                *) echo "" ;;
            esac ;;
        python3-dev)
            case "$PKG_MGR" in
                apt) echo "python3-dev" ;;
                dnf|yum) echo "python3-devel" ;;
                zypper) echo "python3-devel" ;;
                apk) echo "python3-dev" ;;
                pacman) echo "" ;;
                brew) echo "" ;;
                *) echo "python3-dev" ;;
            esac ;;
        build-essential)
            case "$PKG_MGR" in
                apt) echo "build-essential" ;;
                dnf|yum) echo "gcc gcc-c++ make" ;;
                pacman) echo "base-devel" ;;
                zypper) echo "gcc gcc-c++ make" ;;
                apk) echo "build-base" ;;
                brew) echo "" ;;
                pkg) echo "gcc gmake" ;;
                *) echo "gcc make" ;;
            esac ;;
        libvips-dev)
            case "$PKG_MGR" in
                apt) echo "libvips-dev" ;;
                dnf|yum) echo "vips-devel" ;;
                pacman) echo "libvips" ;;
                zypper) echo "libvips-devel" ;;
                apk) echo "vips-dev" ;;
                brew) echo "vips" ;;
                pkg) echo "vips" ;;
                *) echo "libvips" ;;
            esac ;;
        sox) echo "sox" ;;
        imagemagick)
            case "$PKG_MGR" in
                *) echo "imagemagick" ;;
            esac ;;
        chromium)
            case "$PKG_MGR" in
                apt) echo "chromium-browser" ;;
                dnf|yum) echo "chromium" ;;
                pacman) echo "chromium" ;;
                zypper) echo "chromium" ;;
                apk) echo "chromium" ;;
                brew) echo "chromium" ;;
                pkg) echo "chromium" ;;
                *) echo "chromium" ;;
            esac ;;
        xvfb)
            case "$PKG_MGR" in
                apt) echo "xvfb" ;;
                dnf|yum) echo "xorg-x11-server-Xvfb" ;;
                pacman) echo "xorg-server-xvfb" ;;
                zypper) echo "xorg-x11-server-extra" ;;
                apk) echo "xvfb" ;;
                *) echo "" ;;
            esac ;;
        x11vnc)
            case "$PKG_MGR" in
                brew) echo "" ;;
                *) echo "x11vnc" ;;
            esac ;;
        fluxbox)
            case "$PKG_MGR" in
                brew) echo "" ;;
                *) echo "fluxbox" ;;
            esac ;;
        scrot)
            case "$PKG_MGR" in
                brew) echo "" ;;
                *) echo "scrot" ;;
            esac ;;
        tor) echo "tor" ;;
        torsocks)
            case "$PKG_MGR" in
                *) echo "torsocks" ;;
            esac ;;
        msmtp) echo "msmtp" ;;
        mailutils)
            case "$PKG_MGR" in
                apt) echo "mailutils" ;;
                dnf|yum) echo "mailx" ;;
                pacman) echo "s-nail" ;;
                zypper) echo "mailx" ;;
                apk) echo "" ;;
                brew) echo "" ;;
                *) echo "" ;;
            esac ;;
        fonts)
            case "$PKG_MGR" in
                apt) echo "fonts-liberation fonts-noto-color-emoji" ;;
                dnf|yum) echo "liberation-fonts google-noto-emoji-color-fonts" ;;
                pacman) echo "ttf-liberation noto-fonts-emoji" ;;
                zypper) echo "liberation-fonts google-noto-coloremoji-fonts" ;;
                apk) echo "font-noto font-noto-emoji" ;;
                brew) echo "" ;;
                *) echo "" ;;
            esac ;;
        *) echo "$generic" ;;
    esac
}

# ---- Install build essentials ----
install_build_tools_local() {
    header "Installing Build Tools"

    if [[ "$OS_TYPE" == "macos" ]]; then
        if ! xcode-select -p &>/dev/null; then
            log "Installing Xcode Command Line Tools..."
            xcode-select --install 2>/dev/null || true
            warn "Please complete the Xcode CLT installation dialog, then re-run this script."
        fi
        if ! command -v brew &>/dev/null; then
            log "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
        fi
        log "Build tools ready (macOS)"
        return
    fi

    local mapped
    mapped=$(pkg_name "build-essential")
    if [[ -n "$mapped" ]]; then
        pkg_install $mapped
    fi

    local extras=()
    for tool in git curl wget jq; do
        command -v "$tool" &>/dev/null || extras+=("$tool")
    done
    if [[ ${#extras[@]} -gt 0 ]]; then
        pkg_install "${extras[@]}"
    fi

    log "Build tools installed"
}
