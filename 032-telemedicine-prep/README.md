# 032 - Telemedicine Visit Prep

Prepare patients for telemedicine visits with tech checks, document collection, and pre-visit questionnaires.

## Quick Start

### Docker (Recommended)
```bash
# Interactive setup
./install.sh

# Or use a pre-configured .env file
cp .env.example .env
# Edit .env with your values
./install.sh --env-file .env
```

### Windows
```powershell
.\install.ps1
```

### Local Installation
```bash
./install.sh --local
```

## Key Integrations
WhatsApp/Telegram, Slack, Cron, Browser

## Extra Dependencies
Chromium

## Configuration

Copy `.env.example` to `.env` and configure:

1. **AI Provider**: Set your xAI/Grok API key (required) and optional provider keys
2. **Channels**: Configure Telegram, Discord, Slack, or WhatsApp tokens
3. **Use-Case Settings**: Configure settings specific to this use case

## Files

| File | Purpose |
|------|---------|
| `install.sh` | Main installer (bash) |
| `install.ps1` | Windows PowerShell bootstrap |
| `docker-compose.yml` | Docker Compose configuration |
| `Dockerfile` | Docker image definition |
| `.env.example` | Environment variable template |
| `openclaw.config.json` | OpenClaw configuration overlay |
| `skills/telemedicine-prep/SKILL.md` | AI skill definition |

## Access URLs

After installation:
- **Gateway**: http://localhost:18789
- **Bridge**: http://localhost:18790
- **noVNC Desktop**: http://localhost:6080 (if VNC enabled)
