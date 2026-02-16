# OpenClaw - Competitor Activity Tracker
FROM node:22-bookworm-slim

LABEL description="OpenClaw - Competitor Activity Tracker"
ENV DEBIAN_FRONTEND=noninteractive

# Base system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl wget ca-certificates gnupg build-essential \
    bash jq lsof procps sudo unzip \
    && rm -rf /var/lib/apt/lists/*

# Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv python3-dev \
    && rm -rf /var/lib/apt/lists/*
RUN python3 -m pip install --break-system-packages --no-cache-dir \
    requests numpy pandas Pillow beautifulsoup4 flask fastapi httpx uvicorn

# Node.js tools
RUN corepack enable && corepack prepare pnpm@latest --activate
RUN npm install -g typescript ts-node nodemon

# Media processing
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg libvips-dev imagemagick sox libsox-fmt-all \
    && rm -rf /var/lib/apt/lists/*

# Browser & display
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium xvfb x11vnc fluxbox scrot xdg-utils \
    fonts-liberation fonts-noto-color-emoji fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc \
    && git clone --depth 1 https://github.com/novnc/websockify.git /opt/novnc/utils/websockify \
    && ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# Tor
RUN apt-get update && apt-get install -y --no-install-recommends tor torsocks \
    && rm -rf /var/lib/apt/lists/*
RUN echo "SocksPort 0.0.0.0:9050" > /etc/tor/torrc \
    && echo "Log notice stdout" >> /etc/tor/torrc

# Email tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    msmtp msmtp-mta mailutils \
    && rm -rf /var/lib/apt/lists/*

# OpenClaw
RUN npm install -g openclaw@latest
# Install all OpenClaw plugins, skills, and channel integrationsRUN npm install -g     @openclaw/skill-browser @openclaw/skill-cron @openclaw/skill-exec     @openclaw/skill-file-system @openclaw/skill-gmail-gog @openclaw/skill-webhooks     @openclaw/skill-nano-pdf @openclaw/skill-todoist @openclaw/skill-trello     @openclaw/skill-obsidian @openclaw/skill-blogwatcher @openclaw/skill-openai-whisper     @openclaw/skill-openai-image-gen @openclaw/skill-spotify-player     @openclaw/skill-openhue @openclaw/skill-eightctl @openclaw/skill-webchat     @openclaw/channel-telegram @openclaw/channel-discord @openclaw/channel-slack     @openclaw/channel-whatsapp @openclaw/channel-webchat @openclaw/channel-teams     @openclaw/plugin-memory @openclaw/plugin-scheduler @openclaw/plugin-analytics     @openclaw/plugin-rate-limiter @openclaw/plugin-logger @openclaw/plugin-backup     @openclaw/plugin-health-check     2>/dev/null || true# Install CLI tools for skillsRUN pip3 install --break-system-packages --no-cache-dir     openai-whisper yt-dlp 2>/dev/null || trueRUN npm install -g gog-cli 2>/dev/null || true

# User setup
RUN mkdir -p /home/node/.openclaw/workspace \
    && chown -R node:node /home/node/.openclaw
RUN echo "node ALL=(ALL) NOPASSWD: /usr/bin/tor, /usr/sbin/service" >> /etc/sudoers.d/node

# Copy skills and config
COPY skills/ /opt/openclaw-skills/
COPY openclaw.config.json /opt/openclaw-config.json
COPY --from=shared entrypoint.sh /usr/local/bin/entrypoint.sh 2>/dev/null || true
COPY entrypoint.sh /usr/local/bin/entrypoint.sh 2>/dev/null || true

ENV DISPLAY=:99 DISPLAY_RESOLUTION=1920x1080x24 ENABLE_VNC=true \
    TOR_ENABLED=true TOR_SOCKS_PORT=9050 OPENCLAW_GATEWAY_BIND=lan \
    OPENCLAW_LOG_LEVEL=info \
    CHROMIUM_FLAGS="--no-sandbox --disable-gpu --disable-dev-shm-usage"

EXPOSE 18789 18790 6080 5900 9050
WORKDIR /home/node
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
