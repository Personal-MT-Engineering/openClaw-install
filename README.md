# OpenClaw Install — 100 Use Cases

One-click deployment of [OpenClaw](https://github.com/OpenClaw/openclaw) for 100 real-world use cases. Each folder is a self-contained installer with cross-platform scripts, Docker support, interactive wizard, and pre-configured AI skills.

## Quick Start

```bash
# Pick a use case (e.g., personal assistant)
cd 081-personal-assistant

# Interactive install (Docker or local)
./install.sh

# Or use a pre-configured .env file
cp .env.example .env
# Edit .env with your API keys
./install.sh --env-file .env

# Windows users
.\install.ps1
```

## Features

- **Cross-platform**: Linux (12+ distros), macOS, WSL, FreeBSD
- **Docker or Local**: Choose containerized or bare-metal installation
- **Interactive Wizard**: Guided setup for AI provider, channels, SMTP, VNC, Tor
- **Non-interactive Mode**: `--env-file` flag for automated deployments
- **All Plugins Included**: Every install downloads all OpenClaw plugins, skills, and channel integrations
- **Pre-configured Skills**: Each use case includes tailored SKILL.md definitions
- **PowerShell Bootstrap**: Windows `.ps1` wrapper auto-detects WSL2 or Git Bash

## Repository Structure

```
openClaw-install/
├── README.md                    # This file
├── _shared/                     # Shared installer library (15 modules)
│   ├── lib-common.sh            # Colors, logging, prompts, CLI parsing
│   ├── lib-detect-os.sh         # OS/distro/package-manager detection
│   ├── lib-docker.sh            # Docker install/check/ensure
│   ├── lib-packages.sh          # Cross-platform package management
│   ├── lib-node.sh              # Node.js 22 installation
│   ├── lib-python.sh            # Python 3 + pip
│   ├── lib-browser.sh           # Chromium + Xvfb + VNC + noVNC
│   ├── lib-media.sh             # ffmpeg, imagemagick, sox, libvips
│   ├── lib-email.sh             # msmtp, mailutils
│   ├── lib-tor.sh               # Tor + torsocks
│   ├── lib-openclaw.sh          # OpenClaw npm install + service start
│   ├── lib-wizard.sh            # Interactive configuration wizard
│   ├── lib-env-generator.sh     # .env file generation
│   ├── lib-env-loader.sh        # .env file loading (--env-file support)
│   ├── lib-plugins.sh           # Plugin & skill auto-downloader
│   ├── base-Dockerfile           # Base Docker image
│   ├── base-docker-compose.yml   # Base compose template
│   ├── base-entrypoint.sh        # Docker entrypoint
│   └── install-common.ps1        # PowerShell WSL2/Git Bash bootstrap
├── 001-email-triage-assistant/
│   ├── install.sh               # Main installer
│   ├── install.ps1              # Windows wrapper
│   ├── docker-compose.yml       # Docker Compose config
│   ├── Dockerfile               # Docker image
│   ├── .env.example             # Environment variable template
│   ├── openclaw.config.json     # OpenClaw config overlay
│   ├── entrypoint.sh            # Docker entrypoint
│   ├── README.md                # Use case documentation
│   └── skills/                  # Custom SKILL.md files
│       └── email-triage/
│           └── SKILL.md
├── 002-calendar-meeting-scheduler/
│   └── ...
├── ...
└── 100-backup-verifier/
    └── ...
```

## All 100 Use Cases

### Sector 1: Administration & Office (001-012)

| # | Folder | Title | Channels | Extra Deps |
|---|--------|-------|----------|------------|
| 001 | [001-email-triage-assistant](./001-email-triage-assistant/) | Email Triage & Auto-Response | Gmail, Slack/Telegram, Cron | gog CLI |
| 002 | [002-calendar-meeting-scheduler](./002-calendar-meeting-scheduler/) | Smart Meeting Scheduler | WhatsApp/Telegram, Browser, Cron | Chromium |
| 003 | [003-document-generator](./003-document-generator/) | Template-Based Document Generator | Slack/Teams, nano-pdf | — |
| 004 | [004-expense-tracker](./004-expense-tracker/) | Receipt Scanning Expense Tracker | WhatsApp/Telegram, Cron | — |
| 005 | [005-meeting-notes-summarizer](./005-meeting-notes-summarizer/) | Meeting Transcript Summarizer | Slack/Teams, Whisper, Cron | Whisper, ffmpeg |
| 006 | [006-hr-onboarding-bot](./006-hr-onboarding-bot/) | Employee Onboarding Automation | Slack/Teams, Cron | — |
| 007 | [007-office-inventory-manager](./007-office-inventory-manager/) | Office Supply Inventory Tracker | Slack, Browser, Cron | Chromium |
| 008 | [008-travel-approval-workflow](./008-travel-approval-workflow/) | Travel Request Approval Workflow | Slack/Teams, Browser | Chromium |
| 009 | [009-timesheet-reporter](./009-timesheet-reporter/) | Timesheet Collection & Reporting | Telegram/Slack, Cron, Trello | Trello skill |
| 010 | [010-visitor-check-in](./010-visitor-check-in/) | Visitor Check-In & Notification | WebChat, Slack/Telegram | — |
| 011 | [011-policy-compliance-checker](./011-policy-compliance-checker/) | Policy Q&A Bot | Slack/Teams, Obsidian | — |
| 012 | [012-mail-merge-sender](./012-mail-merge-sender/) | Personalized Bulk Email Sender | Gmail, Telegram/Slack | gog CLI |

### Sector 2: Software Development (013-024)

| # | Folder | Title | Channels | Extra Deps |
|---|--------|-------|----------|------------|
| 013 | [013-code-review-assistant](./013-code-review-assistant/) | PR Code Review Bot | GitHub, Webhooks, Discord/Slack | gh CLI |
| 014 | [014-cicd-monitor](./014-cicd-monitor/) | CI/CD Pipeline Monitor | GitHub, Webhooks, Slack/Discord, Cron | gh CLI |
| 015 | [015-bug-triage-bot](./015-bug-triage-bot/) | Bug Priority Assignment Bot | GitHub, Slack/Discord, Cron, Webhooks | gh CLI |
| 016 | [016-documentation-generator](./016-documentation-generator/) | API & Code Docs Generator | GitHub, File system, Slack | gh CLI |
| 017 | [017-dependency-updater](./017-dependency-updater/) | Dependency Version Monitor | GitHub, Cron, Browser, Slack | gh CLI |
| 018 | [018-deployment-automation](./018-deployment-automation/) | Chat-Driven Deployment | Slack/Discord, Exec, GitHub | ssh, kubectl |
| 019 | [019-changelog-release-manager](./019-changelog-release-manager/) | Changelog & Release Manager | GitHub, Slack/Discord, Exec, Cron | gh CLI |
| 020 | [020-code-snippet-library](./020-code-snippet-library/) | Team Code Snippet Library | Slack/Discord, File system, Obsidian | — |
| 021 | [021-database-query-assistant](./021-database-query-assistant/) | Natural Language DB Query | Slack/Teams, Exec | psql/mysql |
| 022 | [022-test-coverage-reporter](./022-test-coverage-reporter/) | Test Coverage Analyzer | GitHub, Exec, Cron, Slack | gh CLI |
| 023 | [023-incident-postmortem-writer](./023-incident-postmortem-writer/) | Postmortem Template Generator | Slack, GitHub | gh CLI |
| 024 | [024-git-workflow-enforcer](./024-git-workflow-enforcer/) | Git Convention Enforcer | GitHub, Webhooks, Slack/Discord | gh CLI |

### Sector 3: Medical & Healthcare (025-032)

| # | Folder | Title | Channels | Extra Deps |
|---|--------|-------|----------|------------|
| 025 | [025-appointment-scheduler](./025-appointment-scheduler/) | Patient Appointment Scheduler | WhatsApp/Telegram, Cron | — |
| 026 | [026-patient-intake-bot](./026-patient-intake-bot/) | Pre-Visit Intake Form Bot | WhatsApp/Telegram, Cron | — |
| 027 | [027-medical-report-summarizer](./027-medical-report-summarizer/) | Lab Result Summarizer | Telegram/Slack, nano-pdf | — |
| 028 | [028-symptom-tracker](./028-symptom-tracker/) | Daily Symptom & Vital Tracker | WhatsApp, Cron | eightctl (optional) |
| 029 | [029-prescription-reminder](./029-prescription-reminder/) | Medication Adherence Reminder | WhatsApp/Telegram, Cron | — |
| 030 | [030-health-faq-bot](./030-health-faq-bot/) | Healthcare Facility FAQ Bot | WebChat, WhatsApp | — |
| 031 | [031-clinical-trial-monitor](./031-clinical-trial-monitor/) | Trial Participant Follow-Up | WhatsApp/Telegram, Cron | — |
| 032 | [032-telemedicine-prep](./032-telemedicine-prep/) | Telemedicine Visit Prep | WhatsApp/Telegram, Browser, Cron | Chromium |

### Sector 4: Social Media & Marketing (033-042)

| # | Folder | Title | Channels | Extra Deps |
|---|--------|-------|----------|------------|
| 033 | [033-content-scheduler](./033-content-scheduler/) | Multi-Platform Content Scheduler | Browser, Cron, Slack/Telegram | Chromium |
| 034 | [034-analytics-reporter](./034-analytics-reporter/) | Social Analytics Reporter | Browser, Cron, Slack | Chromium |
| 035 | [035-community-manager](./035-community-manager/) | Discord/Slack Community Manager | Discord/Slack, Cron | — |
| 036 | [036-influencer-outreach](./036-influencer-outreach/) | Influencer Discovery & Outreach | Browser, Gmail, Slack | Chromium, gog CLI |
| 037 | [037-seo-monitor](./037-seo-monitor/) | SEO Ranking & Keyword Tracker | Browser, Cron, Slack/Telegram | Chromium |
| 038 | [038-hashtag-trend-tracker](./038-hashtag-trend-tracker/) | Hashtag & Topic Trend Tracker | Browser, Cron, Slack | Chromium |
| 039 | [039-brand-mention-monitor](./039-brand-mention-monitor/) | Brand Mention Sentiment Monitor | Browser, blogwatcher, Cron, Slack | Chromium |
| 040 | [040-email-campaign-manager](./040-email-campaign-manager/) | Email Marketing Campaign Manager | Gmail, Cron, Slack | gog CLI |
| 041 | [041-competitor-tracker](./041-competitor-tracker/) | Competitor Activity Tracker | Browser, Cron, Slack | Chromium |
| 042 | [042-ugc-curator](./042-ugc-curator/) | User-Generated Content Curator | Browser, Gmail, Slack | Chromium, gog CLI |

### Sector 5: Education & Research (043-050)

| # | Folder | Title | Channels | Extra Deps |
|---|--------|-------|----------|------------|
| 043 | [043-tutoring-assistant](./043-tutoring-assistant/) | Personalized AI Tutor | WhatsApp/Telegram, Cron | — |
| 044 | [044-research-paper-summarizer](./044-research-paper-summarizer/) | Literature Review Assistant | Telegram/Slack, nano-pdf, Browser | Chromium |
| 045 | [045-quiz-generator](./045-quiz-generator/) | Automated Quiz Generator | Telegram/Discord/Slack | — |
| 046 | [046-student-progress-tracker](./046-student-progress-tracker/) | Student Progress & Parent Comm | Slack, WhatsApp, Cron | — |
| 047 | [047-citation-manager](./047-citation-manager/) | Citation & Bibliography Manager | Browser, Telegram/Slack | Chromium |
| 048 | [048-language-learning-bot](./048-language-learning-bot/) | Language Learning Practice Bot | WhatsApp/Telegram, Cron | — |
| 049 | [049-thesis-writing-coach](./049-thesis-writing-coach/) | Thesis Writing Coach | Slack/Telegram, Cron | — |
| 050 | [050-study-group-coordinator](./050-study-group-coordinator/) | Study Group Coordinator | Discord, Cron, Browser | Chromium |

### Sector 6: Finance & Accounting (051-058)

| # | Folder | Title | Channels | Extra Deps |
|---|--------|-------|----------|------------|
| 051 | [051-invoice-manager](./051-invoice-manager/) | Invoice Generation & Tracking | Slack/Telegram, Gmail, nano-pdf, Cron | gog CLI |
| 052 | [052-expense-categorizer](./052-expense-categorizer/) | Bank Transaction Categorizer | Telegram/Slack | — |
| 053 | [053-financial-report-generator](./053-financial-report-generator/) | Monthly Financial Reporter | Gmail, nano-pdf, Cron, Slack | gog CLI |
| 054 | [054-tax-prep-assistant](./054-tax-prep-assistant/) | Tax Document Organizer | Telegram/Slack, Cron | — |
| 055 | [055-budget-tracker](./055-budget-tracker/) | Budget Variance Tracker | Slack, Cron, Gmail | gog CLI |
| 056 | [056-payroll-calculator](./056-payroll-calculator/) | Payroll Calculation Assistant | Gmail, nano-pdf, Cron | gog CLI |
| 057 | [057-crypto-portfolio-tracker](./057-crypto-portfolio-tracker/) | Crypto Portfolio Tracker | Browser, Cron, Telegram/WhatsApp | Chromium |
| 058 | [058-subscription-manager](./058-subscription-manager/) | SaaS Subscription Tracker | Browser, Cron, Slack | Chromium |

### Sector 7: Legal (059-064)

| # | Folder | Title | Channels | Extra Deps |
|---|--------|-------|----------|------------|
| 059 | [059-contract-reviewer](./059-contract-reviewer/) | Contract Clause Risk Analyzer | Slack/Telegram, nano-pdf | — |
| 060 | [060-case-management](./060-case-management/) | Legal Case & Deadline Tracker | Slack/Teams, Cron, Gmail | gog CLI |
| 061 | [061-legal-research-assistant](./061-legal-research-assistant/) | Legal Research & Case Law Finder | Browser, Slack, Obsidian | Chromium |
| 062 | [062-compliance-monitor](./062-compliance-monitor/) | Regulatory Change Monitor | Browser, blogwatcher, Cron, Slack | Chromium |
| 063 | [063-nda-generator](./063-nda-generator/) | NDA & Legal Document Generator | Slack/Telegram, nano-pdf, Gmail | gog CLI |
| 064 | [064-ip-portfolio-tracker](./064-ip-portfolio-tracker/) | Intellectual Property Tracker | Browser, Cron, Slack | Chromium |

### Sector 8: Customer Service & Support (065-072)

| # | Folder | Title | Channels | Extra Deps |
|---|--------|-------|----------|------------|
| 065 | [065-ticket-triage](./065-ticket-triage/) | Support Ticket Auto-Triage | Gmail, Slack, Webhooks | gog CLI |
| 066 | [066-faq-support-bot](./066-faq-support-bot/) | Multi-Channel FAQ Bot | WhatsApp/Telegram/Discord/WebChat | — |
| 067 | [067-escalation-manager](./067-escalation-manager/) | SLA Escalation Manager | Slack, Trello, Cron | Trello skill |
| 068 | [068-feedback-analyzer](./068-feedback-analyzer/) | Customer Feedback Analyzer | Browser, Gmail, Cron, Slack | Chromium, gog CLI |
| 069 | [069-knowledge-base-updater](./069-knowledge-base-updater/) | Knowledge Base Auto-Updater | Slack, Browser, Cron | Chromium |
| 070 | [070-customer-onboarding](./070-customer-onboarding/) | Customer Product Onboarding | WhatsApp/Telegram, Cron, Webhooks | — |
| 071 | [071-return-processor](./071-return-processor/) | Return & Refund Processor | WhatsApp/Telegram, Browser, Gmail | Chromium, gog CLI |
| 072 | [072-csat-survey-bot](./072-csat-survey-bot/) | CSAT & NPS Survey Bot | WhatsApp/Telegram, Cron, Slack | — |

### Sector 9: E-Commerce & Sales (073-080)

| # | Folder | Title | Channels | Extra Deps |
|---|--------|-------|----------|------------|
| 073 | [073-order-tracker](./073-order-tracker/) | Order Status & Shipping Bot | WhatsApp/Telegram, Browser, Webhooks | Chromium |
| 074 | [074-inventory-monitor](./074-inventory-monitor/) | Inventory Level Monitor | Browser, Webhooks, Cron, Slack | Chromium |
| 075 | [075-price-monitor](./075-price-monitor/) | Competitor Price Monitor | Browser, Cron, Slack | Chromium |
| 076 | [076-lead-qualifier](./076-lead-qualifier/) | Inbound Lead Scoring Bot | WebChat/WhatsApp, Slack, Webhooks | — |
| 077 | [077-cart-abandonment-recovery](./077-cart-abandonment-recovery/) | Cart Abandonment Recovery | WhatsApp, Gmail, Webhooks, Cron | gog CLI |
| 078 | [078-product-review-aggregator](./078-product-review-aggregator/) | Product Review Insights Engine | Browser, Cron, Slack | Chromium |
| 079 | [079-sales-pipeline-tracker](./079-sales-pipeline-tracker/) | Sales Pipeline Tracker | Slack, Cron, Trello | Trello (optional) |
| 080 | [080-product-catalog-assistant](./080-product-catalog-assistant/) | Product Q&A & Recommendation Bot | WhatsApp/WebChat, Browser | — |

### Sector 10: Personal Productivity (081-088)

| # | Folder | Title | Channels | Extra Deps |
|---|--------|-------|----------|------------|
| 081 | [081-personal-assistant](./081-personal-assistant/) | All-in-One Personal Assistant | WhatsApp/Telegram, Cron, Browser | Chromium |
| 082 | [082-habit-tracker](./082-habit-tracker/) | Daily Habit Streak Tracker | WhatsApp/Telegram, Cron | eightctl (optional) |
| 083 | [083-meal-planner](./083-meal-planner/) | Meal Planner & Grocery List | WhatsApp/Telegram, Cron, Browser | Chromium |
| 084 | [084-travel-planner](./084-travel-planner/) | Travel Itinerary Planner | WhatsApp/Telegram, Browser, Cron | Chromium |
| 085 | [085-home-automation](./085-home-automation/) | Smart Home Control Hub | WhatsApp/Telegram, openhue, Cron | Hue Bridge |
| 086 | [086-personal-journal](./086-personal-journal/) | Daily Journaling Assistant | WhatsApp/Telegram, Cron, Obsidian | — |
| 087 | [087-fitness-coach](./087-fitness-coach/) | Fitness Coach & Workout Planner | WhatsApp/Telegram, Cron | eightctl |
| 088 | [088-reading-list-manager](./088-reading-list-manager/) | Reading List & Book Summary | Telegram/WhatsApp, Cron, Browser | Chromium |

### Sector 11: Creative & Content (089-094)

| # | Folder | Title | Channels | Extra Deps |
|---|--------|-------|----------|------------|
| 089 | [089-writing-assistant](./089-writing-assistant/) | Long-Form Writing Editor | Slack/Telegram, Obsidian | — |
| 090 | [090-podcast-production](./090-podcast-production/) | Podcast Production Assistant | Telegram/Slack, Whisper, Cron | Whisper, ffmpeg |
| 091 | [091-video-script-generator](./091-video-script-generator/) | Video Script & Storyboard Gen | Slack/Telegram, Image Gen | — |
| 092 | [092-newsletter-writer](./092-newsletter-writer/) | Newsletter Content Curator | Browser, blogwatcher, Gmail, Cron | Chromium, gog CLI |
| 093 | [093-music-discovery-curator](./093-music-discovery-curator/) | Music Discovery & Playlist | Spotify, Sonos, Telegram/WhatsApp | spotify-player |
| 094 | [094-social-media-content-writer](./094-social-media-content-writer/) | Social Media Post Writer | Slack, Image Gen, Browser | Chromium |

### Sector 12: DevOps & Infrastructure (095-100)

| # | Folder | Title | Channels | Extra Deps |
|---|--------|-------|----------|------------|
| 095 | [095-server-monitor](./095-server-monitor/) | Server Health Monitor | Exec (SSH), Cron, Slack/Telegram | ssh |
| 096 | [096-incident-responder](./096-incident-responder/) | Incident Response Runbook | Webhooks, Exec, Slack, Cron | ssh, kubectl |
| 097 | [097-log-analyzer](./097-log-analyzer/) | Application Log Anomaly Detector | Exec, Cron, Slack | ssh, kubectl |
| 098 | [098-ssl-cert-monitor](./098-ssl-cert-monitor/) | SSL Certificate Expiry Monitor | Exec, Cron, Slack/Telegram | openssl |
| 099 | [099-container-orchestrator](./099-container-orchestrator/) | Docker Container Lifecycle Mgr | Exec, Slack/Discord, Cron | Docker CLI |
| 100 | [100-backup-verifier](./100-backup-verifier/) | Backup Integrity Verifier | Exec, Cron, Slack | restic/borg |

## Plugins & Skills Auto-Download

Every installer automatically downloads and installs the complete OpenClaw ecosystem:

### Skills (17 packages)
`browser`, `cron`, `exec`, `file-system`, `gmail-gog`, `webhooks`, `nano-pdf`, `todoist`, `trello`, `obsidian`, `blogwatcher`, `openai-whisper`, `openai-image-gen`, `spotify-player`, `openhue`, `eightctl`, `webchat`

### Channel Plugins (6 packages)
`telegram`, `discord`, `slack`, `whatsapp`, `webchat`, `teams`

### Utility Plugins (7 packages)
`memory`, `scheduler`, `analytics`, `rate-limiter`, `logger`, `backup`, `health-check`

### CLI Tools
`gog` (Gmail), `gh` (GitHub), `whisper` (speech-to-text), `yt-dlp` (media download)

## Non-Interactive Mode

For automated deployments, use the `--env-file` flag:

```bash
cp .env.example .env
# Fill in your values
./install.sh --env-file .env
```

When `--env-file` is provided, the wizard is skipped and all values come from the file. Missing critical values will prompt interactively.

## Shared Library Modules

The `_shared/` directory contains 15 reusable bash modules:

| Module | Purpose |
|--------|---------|
| `lib-common.sh` | Colors, logging, prompts, CLI argument parsing |
| `lib-detect-os.sh` | OS type, distro, and package manager detection |
| `lib-docker.sh` | Docker installation and management across all platforms |
| `lib-packages.sh` | Cross-platform package installation with name mapping |
| `lib-node.sh` | Node.js 22 installation via native package managers |
| `lib-python.sh` | Python 3 + pip + common packages |
| `lib-browser.sh` | Chromium + Xvfb + VNC + noVNC |
| `lib-media.sh` | ffmpeg, imagemagick, sox, libvips |
| `lib-email.sh` | msmtp + mailutils |
| `lib-tor.sh` | Tor + torsocks |
| `lib-openclaw.sh` | OpenClaw npm installation + service lifecycle |
| `lib-wizard.sh` | Interactive setup wizard (AI, channels, SMTP, VNC, Tor, gateway) |
| `lib-env-generator.sh` | Generate .env file from wizard variables |
| `lib-env-loader.sh` | Load .env file for non-interactive mode |
| `lib-plugins.sh` | Download all OpenClaw plugins, skills, and CLI tools |

## Supported Platforms

| Platform | Package Manager | Status |
|----------|----------------|--------|
| Ubuntu/Debian | apt | Full support |
| Fedora | dnf | Full support |
| CentOS/RHEL/Rocky | dnf/yum | Full support |
| Arch/Manjaro | pacman | Full support |
| openSUSE | zypper | Full support |
| Alpine | apk | Full support |
| Gentoo | emerge | Full support |
| Void | xbps | Full support |
| NixOS | nix | Full support |
| macOS | brew | Full support |
| FreeBSD | pkg | Full support |
| WSL2 | (host distro) | Full support |
| Windows | PowerShell | Via WSL2/Git Bash |

## License

MIT
