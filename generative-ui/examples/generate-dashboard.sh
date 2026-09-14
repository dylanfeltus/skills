#!/bin/bash
# generate-dashboard.sh — Generate a live system dashboard and push to canvas
# Usage: ./generate-dashboard.sh [output-path]
#
# This script generates a real dashboard with live system data:
# - CPU / memory / disk usage
# - Recent git commits across repos
# - Uptime and load averages
# - Current time with ambient styling
#
# Output: Self-contained HTML file ready for canvas display

set -euo pipefail

OUTPUT="${1:-$HOME/.openclaw/canvas/system-dashboard.html}"
mkdir -p "$(dirname "$OUTPUT")"

# ── Gather System Data ──────────────────────────────────────────────

HOSTNAME=$(hostname)
UPTIME=$(uptime | sed 's/.*up //' | sed 's/,.*//')
LOAD=$(sysctl -n vm.loadavg 2>/dev/null | tr -d '{}' || uptime | grep -o 'load average.*' | cut -d: -f2)

# CPU usage (macOS)
CPU_IDLE=$(top -l 1 -n 0 2>/dev/null | grep "CPU usage" | awk '{print $7}' | tr -d '%' || echo "0")
CPU_USED=$(echo "100 - ${CPU_IDLE:-0}" | bc 2>/dev/null || echo "??")

# Memory (macOS)
MEM_TOTAL=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.0f", $1/1073741824}' || echo "??")
MEM_PRESSURE=$(memory_pressure 2>/dev/null | grep "System-wide" | head -1 | grep -o '[0-9]*%' || echo "??")

# Disk
DISK_USED=$(df -h / | tail -1 | awk '{print $5}')
DISK_AVAIL=$(df -h / | tail -1 | awk '{print $4}')

# Recent git commits (scan ~/Code for repos)
GIT_COMMITS=""
for repo in "$HOME/Code"/*/; do
  if [ -d "$repo/.git" ]; then
    REPO_NAME=$(basename "$repo")
    COMMITS=$(cd "$repo" && git log --oneline --since="7 days ago" -3 2>/dev/null || true)
    if [ -n "$COMMITS" ]; then
      while IFS= read -r line; do
        HASH=$(echo "$line" | cut -c1-7)
        MSG=$(echo "$line" | cut -c9-)
        GIT_COMMITS="$GIT_COMMITS<div class=\"commit\"><span class=\"commit-repo\">$REPO_NAME</span><span class=\"commit-hash\">$HASH</span><span class=\"commit-msg\">$MSG</span></div>"
      done <<< "$COMMITS"
    fi
  fi
done

[ -z "$GIT_COMMITS" ] && GIT_COMMITS='<div class="commit"><span class="commit-msg" style="color:var(--text-secondary)">No recent commits</span></div>'

# Date/time
NOW=$(date "+%H:%M")
DATE_FULL=$(date "+%A, %B %d, %Y")
GENERATED=$(date "+%Y-%m-%d %H:%M:%S")

# ── Generate HTML ────────────────────────────────────────────────────

cat > "$OUTPUT" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>System Dashboard</title>
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  :root {
    --bg: #0a0a0f;
    --surface: rgba(255,255,255,0.04);
    --surface-hover: rgba(255,255,255,0.07);
    --border: rgba(255,255,255,0.08);
    --text: rgba(255,255,255,0.92);
    --text-dim: rgba(255,255,255,0.50);
    --accent: #6366f1;
    --green: #22c55e;
    --amber: #f59e0b;
    --red: #ef4444;
    --blue: #3b82f6;
  }
  html, body {
    height: 100%; background: var(--bg); color: var(--text);
    font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', system-ui, sans-serif;
    overflow: hidden; -webkit-font-smoothing: antialiased;
  }
  body {
    background: linear-gradient(160deg, #0a0a0f 0%, #0f0f1a 40%, #0d0a1a 100%);
  }
  .container {
    height: 100vh; display: grid;
    grid-template-rows: auto 1fr auto;
    padding: clamp(24px, 3vw, 48px);
    gap: clamp(16px, 2vw, 32px);
  }
  .header {
    display: flex; justify-content: space-between; align-items: baseline;
  }
  .header h1 {
    font-size: 15px; font-weight: 600; letter-spacing: 1px;
    text-transform: uppercase; color: var(--text-dim);
  }
  .header .clock {
    font-size: 15px; font-weight: 500; color: var(--text-dim);
    font-variant-numeric: tabular-nums;
  }
  .grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-template-rows: auto 1fr;
    gap: clamp(12px, 1.5vw, 20px);
  }
  .card {
    background: var(--surface); border: 1px solid var(--border);
    border-radius: 16px; padding: clamp(16px, 2vw, 28px);
    display: flex; flex-direction: column; gap: 8px;
  }
  .card-label {
    font-size: 11px; font-weight: 600; letter-spacing: 1.2px;
    text-transform: uppercase; color: var(--text-dim);
  }
  .card-value {
    font-size: clamp(32px, 4vw, 52px); font-weight: 700;
    letter-spacing: -1px; line-height: 1; font-variant-numeric: tabular-nums;
  }
  .card-sub { font-size: 13px; color: var(--text-dim); }
  .commits-card { grid-column: 1 / -1; overflow: hidden; }
  .commit {
    display: flex; align-items: baseline; gap: 12px;
    padding: 8px 0; border-bottom: 1px solid var(--border);
    font-size: 13px;
  }
  .commit:last-child { border-bottom: none; }
  .commit-repo {
    font-weight: 600; color: var(--accent);
    min-width: 100px; font-size: 11px;
    text-transform: uppercase; letter-spacing: 0.5px;
  }
  .commit-hash {
    font-family: 'SF Mono', 'Fira Code', monospace;
    color: var(--text-dim); font-size: 12px;
  }
  .commit-msg { color: var(--text); flex: 1; }
  .commits-scroll {
    overflow-y: auto; max-height: 100%; flex: 1;
    scrollbar-width: none;
  }
  .commits-scroll::-webkit-scrollbar { display: none; }
  .footer {
    display: flex; justify-content: space-between;
    color: var(--text-dim); font-size: 11px;
  }
  .progress-ring {
    width: 48px; height: 48px; margin-top: auto;
  }
  .progress-ring circle {
    fill: none; stroke-width: 4; stroke-linecap: round;
  }
  .progress-ring .bg { stroke: var(--border); }
  .glow {
    position: fixed; width: 350px; height: 350px; border-radius: 50%;
    background: radial-gradient(circle, rgba(99,102,241,0.06) 0%, transparent 70%);
    pointer-events: none; animation: drift 25s ease-in-out infinite;
  }
  .glow-1 { top: -80px; right: -80px; }
  .glow-2 { bottom: -120px; left: -80px; animation-delay: -12s;
    background: radial-gradient(circle, rgba(139,92,246,0.04) 0%, transparent 70%);
  }
  @keyframes drift {
    0%, 100% { transform: translate(0,0); }
    33% { transform: translate(-25px, 15px); }
    66% { transform: translate(15px, -25px); }
  }
</style>
</head>
<body>
<div class="glow glow-1"></div>
<div class="glow glow-2"></div>
<div class="container">
  <header class="header">
HTMLEOF

# Inject dynamic data
cat >> "$OUTPUT" << EOF
    <h1>$HOSTNAME</h1>
    <span class="clock" id="clock">$NOW</span>
  </header>
  <div class="grid">
    <div class="card">
      <div class="card-label">CPU</div>
      <div class="card-value">${CPU_USED}%</div>
      <div class="card-sub">Load: $LOAD</div>
    </div>
    <div class="card">
      <div class="card-label">Memory</div>
      <div class="card-value">${MEM_PRESSURE}</div>
      <div class="card-sub">${MEM_TOTAL} GB total</div>
    </div>
    <div class="card">
      <div class="card-label">Disk</div>
      <div class="card-value">$DISK_USED</div>
      <div class="card-sub">$DISK_AVAIL available</div>
    </div>
    <div class="card commits-card">
      <div class="card-label">Recent Commits (7 days)</div>
      <div class="commits-scroll">
        $GIT_COMMITS
      </div>
    </div>
  </div>
  <footer class="footer">
    <span>Up $UPTIME · Generated $GENERATED</span>
    <span>$DATE_FULL · Generative UI</span>
  </footer>
</div>
EOF

cat >> "$OUTPUT" << 'HTMLEOF'
<script>
function updateClock() {
  const now = new Date();
  const h = String(now.getHours()).padStart(2,'0');
  const m = String(now.getMinutes()).padStart(2,'0');
  const s = String(now.getSeconds()).padStart(2,'0');
  document.getElementById('clock').textContent = `${h}:${m}:${s}`;
}
setInterval(updateClock, 1000);
updateClock();
</script>
</body>
</html>
HTMLEOF

echo "✅ Dashboard generated: $OUTPUT"
echo "   Push to canvas with:"
echo "   canvas(action='present', url='file://$OUTPUT')"
