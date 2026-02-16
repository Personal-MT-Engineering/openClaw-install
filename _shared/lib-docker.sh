#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - Docker Installation & Management
# ============================================================================

check_docker() {
    if command -v docker &>/dev/null && docker info &>/dev/null; then
        log "Docker is installed and running"
        log "  Version: $(docker --version)"
        return 0
    fi
    return 1
}

check_docker_compose() {
    if docker compose version &>/dev/null; then
        log "Docker Compose is available"
        log "  Version: $(docker compose version --short 2>/dev/null || echo 'v2+')"
        return 0
    fi
    return 1
}

install_docker_linux() {
    log "Installing Docker Engine..."
    case "$PKG_MGR" in
        apt)
            sudo apt-get update
            sudo apt-get install -y ca-certificates curl gnupg
            sudo install -m 0755 -d /etc/apt/keyrings
            local docker_distro="$DISTRO"
            case "$DISTRO" in
                linuxmint|pop|elementary|zorin|kali) docker_distro="ubuntu" ;;
                raspbian) docker_distro="debian" ;;
            esac
            curl -fsSL "https://download.docker.com/linux/${docker_distro}/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null || true
            sudo chmod a+r /etc/apt/keyrings/docker.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${docker_distro} $(. /etc/os-release && echo "${VERSION_CODENAME:-$(lsb_release -cs 2>/dev/null || echo stable)}") stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        dnf)
            sudo dnf -y install dnf-plugins-core
            sudo dnf config-manager --add-repo "https://download.docker.com/linux/${DISTRO}/docker-ce.repo" 2>/dev/null || \
                sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        yum)
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        pacman)
            sudo pacman -Sy --noconfirm docker docker-compose docker-buildx
            ;;
        zypper)
            sudo zypper install -y docker docker-compose
            ;;
        apk)
            sudo apk add docker docker-compose
            sudo rc-update add docker default
            ;;
        *)
            warn "Unknown package manager. Trying Docker convenience script..."
            curl -fsSL https://get.docker.com | sudo sh
            ;;
    esac

    # Start Docker
    if command -v systemctl &>/dev/null; then
        sudo systemctl enable docker
        sudo systemctl start docker
    elif command -v rc-service &>/dev/null; then
        sudo rc-service docker start
    elif command -v service &>/dev/null; then
        sudo service docker start
    fi

    # Add current user to docker group
    if ! groups | grep -q docker; then
        sudo usermod -aG docker "$USER" 2>/dev/null || true
        warn "Added $USER to docker group. You may need to log out and back in."
    fi
}

install_docker_macos() {
    log "Installing Docker Desktop for macOS..."
    if command -v brew &>/dev/null; then
        brew install --cask docker
    else
        local arch dmg_url
        arch="$(uname -m)"
        if [[ "$arch" == "arm64" ]]; then
            dmg_url="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
        else
            dmg_url="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
        fi
        log "Downloading Docker Desktop..."
        curl -fsSL -o /tmp/Docker.dmg "$dmg_url"
        sudo hdiutil attach /tmp/Docker.dmg -nobrowse
        sudo cp -R "/Volumes/Docker/Docker.app" /Applications/
        sudo hdiutil detach "/Volumes/Docker"
        rm -f /tmp/Docker.dmg
        open /Applications/Docker.app
    fi
    log "Waiting for Docker daemon to start..."
    local retries=0
    while ! docker info &>/dev/null; do
        retries=$((retries + 1))
        if (( retries >= 60 )); then
            err "Docker daemon did not start. Please open Docker Desktop manually and re-run."
            exit 1
        fi
        sleep 3
    done
    log "Docker Desktop is running"
}

install_docker_wsl() {
    log "For WSL, Docker Desktop for Windows is recommended."
    log "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    log "Make sure to enable 'Use the WSL 2 based engine' in Docker Desktop settings."
    echo ""
    if prompt_yesno "Is Docker Desktop already installed and running on Windows?"; then
        local retries=0
        while ! docker info &>/dev/null; do
            retries=$((retries + 1))
            if (( retries >= 20 )); then
                err "Cannot connect to Docker from WSL."
                exit 1
            fi
            warn "Waiting for Docker... (attempt ${retries}/20)"
            sleep 3
        done
        log "Docker is accessible from WSL"
    else
        err "Please install Docker Desktop for Windows first, then re-run this script."
        exit 1
    fi
}

ensure_docker() {
    header "Checking Docker Installation"
    if check_docker; then
        check_docker_compose || true
        return
    fi
    warn "Docker is not installed or not running."
    if ! prompt_yesno "Install Docker now?" "y"; then
        err "Docker is required for Docker mode. Exiting."
        exit 1
    fi
    case "$OS_TYPE" in
        linux)   install_docker_linux ;;
        macos)   install_docker_macos ;;
        wsl)     install_docker_wsl ;;
        freebsd)
            sudo pkg install -y docker docker-compose
            sudo sysrc docker_enable=YES
            sudo service docker start
            ;;
    esac
    if ! check_docker; then
        err "Docker installation failed or daemon not running."
        exit 1
    fi
    check_docker_compose || true
}
