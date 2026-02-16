#!/usr/bin/env bash
# ============================================================================
# OpenClaw Shared Library - Node.js 22 Installation
# ============================================================================

install_node_local() {
    header "Installing Node.js 22"

    if command -v node &>/dev/null; then
        local node_major
        node_major=$(node -v | sed 's/v\([0-9]*\).*/\1/')
        if (( node_major >= 22 )); then
            log "Node.js $(node -v) already installed (>= 22)"
            return
        fi
        warn "Node.js $(node -v) found but need >= 22. Upgrading..."
    fi

    case "$PKG_MGR" in
        apt)
            curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        dnf)
            curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
            sudo dnf install -y nodejs
            ;;
        yum)
            curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
            sudo yum install -y nodejs
            ;;
        pacman)
            sudo pacman -Sy --noconfirm nodejs npm
            ;;
        zypper)
            curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
            sudo zypper install -y nodejs22
            ;;
        apk)
            sudo apk add nodejs npm
            ;;
        brew)
            brew install node@22
            brew link --overwrite node@22 2>/dev/null || true
            ;;
        pkg)
            sudo pkg install -y node22 npm
            ;;
        emerge)
            sudo emerge --ask=n net-libs/nodejs
            ;;
        xbps)
            sudo xbps-install -Sy nodejs
            ;;
        nix)
            nix-env -iA nixpkgs.nodejs_22 2>/dev/null || nix-env -iA nixos.nodejs_22 2>/dev/null
            ;;
        *)
            warn "Installing Node.js via nvm as fallback..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            # shellcheck source=/dev/null
            [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
            nvm install 22
            nvm use 22
            ;;
    esac

    # Enable corepack for pnpm
    if command -v corepack &>/dev/null; then
        corepack enable 2>/dev/null || sudo corepack enable 2>/dev/null || true
        corepack prepare pnpm@latest --activate 2>/dev/null || true
    fi

    # Global Node tools
    log "Installing global Node.js tools..."
    npm install -g typescript ts-node nodemon 2>/dev/null || sudo npm install -g typescript ts-node nodemon

    log "Node.js $(node -v) installed"
}
