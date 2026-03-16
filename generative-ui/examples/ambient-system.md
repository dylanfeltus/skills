# Ambient System Dashboard — Setup Guide

## What This Is

`generate-dashboard.sh` creates a live system dashboard from real data:
- CPU, memory, disk usage
- Recent git commits across all repos in `~/Code/`
- Uptime, load averages
- Current time with ambient dark styling

It outputs a self-contained HTML file — no dependencies, no CDN, no build step.

## Quick Start

```bash
# Generate once
./generate-dashboard.sh

# Output goes to ~/.openclaw/canvas/system-dashboard.html by default
# Or specify a path:
./generate-dashboard.sh /tmp/my-dashboard.html
```

## Push to Canvas Display

```python
# From an agent:
canvas(action="present", node="office-tv",
       url="http://localhost:18789/__openclaw__/canvas/system-dashboard.html")
```

## Auto-Refresh (Cron)

Regenerate every 5 minutes for a live ambient display:

```bash
# Add to crontab -e
*/5 * * * * /path/to/generate-dashboard.sh >> /tmp/dashboard-gen.log 2>&1
```

The HTML includes a live JavaScript clock, so time updates in real-time between regenerations. System metrics refresh on each script run.

## Agent Automation Pattern

An agent can regenerate and push in one step:

```bash
# In an agent task:
exec("bash /path/to/generate-dashboard.sh")
canvas(action="navigate", node="office-tv",
       url="http://localhost:18789/__openclaw__/canvas/system-dashboard.html?t=$(date +%s)")
```

## Customization

Edit the script to add/remove cards. The HTML uses CSS Grid — add cards to `.grid` and they'll auto-layout. Key sections:

- **System data gathering** — top of script, uses `sysctl`, `top`, `df`
- **Git commits** — scans `~/Code/*/` for repos
- **Styling** — CSS variables in `:root`, dark theme by default
- **Layout** — 3-column grid, commits span full width

## Platform Notes

- Currently macOS-specific (`sysctl`, `memory_pressure`, `top -l`)
- Linux adaptation: replace with `/proc/meminfo`, `free`, `mpstat`
