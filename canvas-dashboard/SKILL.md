# Canvas Dashboard

> **What:** Create live, auto-refreshing HTML dashboards and push them to any canvas-connected display surface (TV, tablet, monitor, Mac mini).
>
> **When to use:** Ambient office displays, live status boards, data dashboards, notification walls, meeting room displays, always-on information radiators.

---

## How Canvas Works

OpenClaw's **canvas** system turns any connected display into a web view controlled by agents. The Gateway serves files at:

```
http://<gateway-ip>:18789/__openclaw__/canvas/
```

**Core workflow:**

1. **Write** an HTML file to the canvas directory (or provide a URL)
2. **Present** it on a node: `canvas(action="present", node="living-room")`
3. **Navigate** to change content: `canvas(action="navigate", url="...")`
4. **Eval** JS to update live: `canvas(action="eval", javaScript="...")`
5. **Snapshot** to see what's showing: `canvas(action="snapshot")`

### Canvas Tool Reference

```python
# Show a page on a specific display
canvas(action="present", node="office-tv", url="http://localhost:18789/__openclaw__/canvas/dashboard.html")

# Navigate to a different page
canvas(action="navigate", node="office-tv", url="http://localhost:18789/__openclaw__/canvas/status.html")

# Run JavaScript on the display (update content without reload)
canvas(action="eval", node="office-tv", javaScript="document.getElementById('count').textContent = '42'")

# Capture what's currently showing
canvas(action="snapshot", node="office-tv")

# Present with dimensions
canvas(action="present", node="office-tv", width=1920, height=1080)
```

### Finding the Canvas Directory

The canvas directory is served by the Gateway. Write files there:

```bash
# Find it (typical location)
ls ~/.openclaw/canvas/
# Or write directly
write("~/.openclaw/canvas/dashboard.html", htmlContent)
```

---

## Dashboard Templates

Three production-ready templates below. Copy the full HTML, customize the data, and push to any display.

---

### Template 1: Status Board

A service health dashboard with status indicators, agent activity, key metrics, and event feed. Dark theme, auto-refreshes every 10 seconds.

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Status Board</title>
<style>
  *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    min-height: 100vh;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
    background: #0d1117; color: #c9d1d9;
    padding: 2.5vw; overflow: hidden;
  }
  header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2vw; }
  header h1 { font-size: clamp(1.4rem, 2.5vw, 2.2rem); font-weight: 600; color: #fff; }
  header .meta { font-size: clamp(0.8rem, 1.2vw, 1rem); opacity: 0.5; }
  .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 1.5vw; }
  .card {
    background: #161b22; border: 1px solid #30363d;
    border-radius: 12px; padding: clamp(1rem, 1.8vw, 1.8rem);
  }
  .card h2 {
    font-size: clamp(0.85rem, 1.2vw, 1.05rem); text-transform: uppercase;
    letter-spacing: 0.08em; opacity: 0.5; margin-bottom: 1rem; font-weight: 500;
  }
  .row { display: flex; justify-content: space-between; align-items: center; padding: 0.55rem 0; border-bottom: 1px solid #21262d; font-size: clamp(0.9rem, 1.3vw, 1.15rem); }
  .row:last-child { border-bottom: none; }
  .dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; margin-right: 0.6rem; }
  .dot.ok   { background: #3fb950; box-shadow: 0 0 6px #3fb95088; }
  .dot.warn { background: #d29922; box-shadow: 0 0 6px #d2992288; }
  .dot.err  { background: #f85149; box-shadow: 0 0 6px #f8514988; }
  .label { display: flex; align-items: center; }
  .value { opacity: 0.6; }
  .big { font-size: clamp(2.4rem, 4vw, 4rem); font-weight: 700; color: #fff; line-height: 1; }
  .sub { font-size: clamp(0.8rem, 1vw, 0.95rem); opacity: 0.45; margin-top: 0.3rem; }
  .stats { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
</style>
</head>
<body>
<header>
  <h1>⚡ System Status</h1>
  <div class="meta">Updated <span id="ts"></span></div>
</header>
<div class="grid">
  <div class="card"><h2>Services</h2><div id="svc"></div></div>
  <div class="card"><h2>Agents</h2><div id="agt"></div></div>
  <div class="card"><h2>Metrics</h2><div class="stats" id="met"></div></div>
  <div class="card"><h2>Recent Events</h2><div id="evt"></div></div>
</div>
<script>
// ——— CUSTOMIZE: Replace these arrays with your real data or fetch calls ———
const services = [
  { name: 'Gateway', status: 'ok' },
  { name: 'Canvas', status: 'ok' },
  { name: 'Scheduler', status: 'ok' },
  { name: 'Database', status: 'warn' },
];
const agents = [
  { name: 'remy', status: 'ok', note: 'Building' },
  { name: 'otto', status: 'ok', note: 'Monitoring' },
  { name: 'scout', status: 'warn', note: 'Idle 8m' },
];

function render() {
  document.getElementById('ts').textContent = new Date().toLocaleTimeString();
  document.getElementById('svc').innerHTML = services.map(s =>
    `<div class="row"><span class="label"><span class="dot ${s.status}"></span>${s.name}</span><span class="value">${s.status === 'ok' ? 'Operational' : 'Degraded'}</span></div>`
  ).join('');
  document.getElementById('agt').innerHTML = agents.map(a =>
    `<div class="row"><span class="label"><span class="dot ${a.status}"></span>${a.name}</span><span class="value">${a.note}</span></div>`
  ).join('');
  document.getElementById('met').innerHTML = [
    [(99.9 + Math.random()*0.09).toFixed(2) + '%', 'Uptime'],
    [Math.floor(130 + Math.random()*30), 'Tasks Today'],
    [Math.floor(40 + Math.random()*25) + 'ms', 'Latency'],
    [Math.floor(1100 + Math.random()*200), 'Messages'],
  ].map(([v,l]) => `<div><div class="big">${v}</div><div class="sub">${l}</div></div>`).join('');
  document.getElementById('evt').innerHTML = [
    'Skill deployed to production',
    'Cron daily-digest completed',
    'Node mac-mini reconnected',
    'Canvas snapshot captured',
    'Agent spawned sub-agent',
  ].map((t,i) => `<div class="row">${t}<span class="value">${i*3+1}m ago</span></div>`).join('');
}
render();
setInterval(render, 10000);
</script>
</body>
</html>
```

---

### Template 2: Metrics Dashboard

KPI cards with sparkline charts. Pure CSS/JS sparklines — no chart library needed.

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Metrics</title>
<style>
  *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    min-height: 100vh;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
    background: #0d1117; color: #c9d1d9;
    padding: 2.5vw; overflow: hidden;
  }
  h1 { font-size: clamp(1.4rem, 2.5vw, 2.2rem); font-weight: 600; color: #fff; margin-bottom: 2vw; }
  .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5vw; }
  .kpi {
    background: #161b22; border: 1px solid #30363d; border-radius: 12px;
    padding: clamp(1.2rem, 2vw, 2rem);
    display: flex; flex-direction: column; justify-content: space-between;
  }
  .kpi-label { font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.1em; opacity: 0.45; }
  .kpi-value { font-size: clamp(2.5rem, 4.5vw, 4.5rem); font-weight: 700; color: #fff; margin: 0.3rem 0; }
  .kpi-delta { font-size: 0.95rem; }
  .kpi-delta.up { color: #3fb950; }
  .kpi-delta.down { color: #f85149; }
  .spark { margin-top: 0.8rem; }
  .spark svg { width: 100%; height: 40px; }
  .spark polyline { fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
  .spark .area { stroke: none; opacity: 0.1; }
</style>
</head>
<body>
<h1>📊 Metrics Dashboard</h1>
<div class="grid" id="grid"></div>
<script>
// ——— CUSTOMIZE: Replace with your own KPIs ———
const kpis = [
  { label: 'Revenue', value: '$48.2K', delta: '+12.3%', up: true },
  { label: 'Active Users', value: '3,847', delta: '+5.1%', up: true },
  { label: 'Error Rate', value: '0.03%', delta: '-18%', up: true },
  { label: 'Avg Response', value: '142ms', delta: '+8ms', up: false },
  { label: 'Deployments', value: '23', delta: '+4 today', up: true },
  { label: 'Uptime', value: '99.97%', delta: '30d rolling', up: true },
];

function sparkData(n) {
  const d = []; let v = 50;
  for (let i = 0; i < n; i++) { v = Math.max(10, Math.min(90, v + (Math.random() - 0.45) * 15)); d.push(v); }
  return d;
}

function sparkSvg(data, color) {
  const w = 200, h = 40, n = data.length;
  const pts = data.map((v, i) => `${(i / (n - 1)) * w},${h - (v / 100) * h}`).join(' ');
  const area = pts + ` ${w},${h} 0,${h}`;
  return `<svg viewBox="0 0 ${w} ${h}" preserveAspectRatio="none">
    <polygon class="area" points="${area}" fill="${color}"/>
    <polyline points="${pts}" stroke="${color}"/>
  </svg>`;
}

document.getElementById('grid').innerHTML = kpis.map(k => {
  const color = k.up ? '#3fb950' : '#f85149';
  return `<div class="kpi">
    <div class="kpi-label">${k.label}</div>
    <div class="kpi-value">${k.value}</div>
    <div class="kpi-delta ${k.up ? 'up' : 'down'}">${k.delta}</div>
    <div class="spark">${sparkSvg(sparkData(20), color)}</div>
  </div>`;
}).join('');
</script>
</body>
</html>
```

---

### Template 3: Ambient Display

Minimal, beautiful always-on display with time, date, and rotating quotes. Slow gradient background shift.

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Ambient</title>
<style>
  *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
  @keyframes bg { 0% { background-position: 0% 50%; } 50% { background-position: 100% 50%; } 100% { background-position: 0% 50%; } }
  @keyframes fadeIn  { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }
  @keyframes fadeOut { from { opacity: 1; } to { opacity: 0; } }
  body {
    height: 100vh; width: 100vw; overflow: hidden;
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
    background: linear-gradient(135deg, #0f0c29, #302b63, #24243e, #0f0c29);
    background-size: 400% 400%; animation: bg 120s ease infinite;
    color: #e0e0e0;
  }
  #time { font-size: clamp(6rem, 14vw, 16rem); font-weight: 200; letter-spacing: -0.02em; color: #fff; }
  #date { font-size: clamp(1.2rem, 2.5vw, 2.4rem); font-weight: 300; margin-top: 0.6rem; opacity: 0.5; text-transform: uppercase; letter-spacing: 0.15em; }
  #quote-box { position: absolute; bottom: 8vh; max-width: 70vw; text-align: center; font-size: clamp(1rem, 1.8vw, 1.6rem); font-weight: 300; font-style: italic; opacity: 0.4; min-height: 3em; }
  #q.in  { animation: fadeIn 0.8s ease forwards; }
  #q.out { animation: fadeOut 0.8s ease forwards; }
</style>
</head>
<body>
<div id="time"></div>
<div id="date"></div>
<div id="quote-box"><span id="q"></span></div>
<script>
// ——— CUSTOMIZE: Edit the quotes array ———
const quotes = [
  "The best way to predict the future is to invent it. — Alan Kay",
  "Simplicity is the ultimate sophistication. — Leonardo da Vinci",
  "Stay hungry, stay foolish. — Steve Jobs",
  "Make it work, make it right, make it fast. — Kent Beck",
  "Any sufficiently advanced technology is indistinguishable from magic. — Arthur C. Clarke",
  "Perfection is achieved when there is nothing left to take away. — Saint-Exupéry",
];
let qi = 0;
const p = s => String(s).padStart(2, '0');
function tick() {
  const d = new Date();
  document.getElementById('time').textContent = `${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`;
  document.getElementById('date').textContent = d.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' });
}
function cycle() {
  const el = document.getElementById('q');
  el.className = 'out';
  setTimeout(() => { qi = (qi + 1) % quotes.length; el.textContent = quotes[qi]; el.className = 'in'; }, 800);
}
document.getElementById('q').textContent = quotes[0];
document.getElementById('q').className = 'in';
tick(); setInterval(tick, 1000); setInterval(cycle, 30000);
</script>
</body>
</html>
```

---

## How to Use

### Step 1: Write the Dashboard

Pick a template above (or build your own), customize the data, and write it to the canvas directory:

```python
# Write the HTML file
write("~/.openclaw/canvas/my-dashboard.html", dashboard_html)
```

### Step 2: Push to a Display

```python
# Show on a specific node
canvas(action="present", node="office-tv", url="http://localhost:18789/__openclaw__/canvas/my-dashboard.html")
```

### Step 3: Update Live

Two approaches for live updates:

**Option A: Self-refreshing dashboard** — The HTML includes `setInterval` that fetches new data from an endpoint or file:

```javascript
// Inside your dashboard HTML
setInterval(async () => {
  const res = await fetch('/api/metrics');
  const data = await res.json();
  document.getElementById('count').textContent = data.count;
}, 10000);
```

**Option B: Agent-pushed updates** — Use `canvas eval` to inject new values:

```python
# Push a single value update
canvas(action="eval", node="office-tv", javaScript="""
  document.getElementById('task-count').textContent = '47';
  document.getElementById('updated').textContent = new Date().toLocaleTimeString();
""")
```

Option B is ideal for event-driven updates (new event → push to display) without the dashboard needing to poll.

### Step 4: Verify

```python
# Capture what's showing
canvas(action="snapshot", node="office-tv")
```

---

## Customization Guide

### Swap Data Sources

Every template has a `CUSTOMIZE` comment marking where to change data. Replace static arrays with:

- **Fetch from an API:** `fetch('/api/data').then(r => r.json()).then(render)`
- **Read from a local JSON file:** `fetch('data.json').then(r => r.json()).then(render)`
- **Agent-pushed via eval:** Keep static data, update via `canvas(action="eval", ...)`

### Change Colors

All templates use CSS custom properties pattern. Key colors:

| Element | Default | Change to |
|---------|---------|-----------|
| Background | `#0d1117` | Any dark color |
| Cards | `#161b22` | Slightly lighter than bg |
| Borders | `#30363d` | Subtle separator |
| OK/Green | `#3fb950` | Keep for positive signals |
| Warn/Yellow | `#d29922` | Keep for warnings |
| Error/Red | `#f85149` | Keep for errors |
| Text | `#c9d1d9` | Light gray on dark |

### Add/Remove Cards

In the Status Board and Metrics templates, cards are generated from arrays. Add or remove entries:

```javascript
// Add a new service to monitor
services.push({ name: 'Redis', status: 'ok' });

// Add a new KPI
kpis.push({ label: 'API Calls', value: '12.4M', delta: '+2.1%', up: true });
```

---

## Auto-Refresh Patterns

### Pattern 1: Self-Polling (dashboard fetches its own data)

```javascript
async function refresh() {
  try {
    const data = await fetch('/api/status').then(r => r.json());
    renderDashboard(data);
  } catch (e) {
    // Show stale data with a warning indicator, don't crash
    document.getElementById('status-indicator').textContent = '⚠ Stale';
  }
}
setInterval(refresh, 10000); // Every 10 seconds
```

### Pattern 2: Agent-Pushed (agent sends updates)

```python
# In your agent's periodic task:
canvas(action="eval", node="tv", javaScript=f"""
  updateMetrics({{ tasks: {task_count}, errors: {error_count} }});
""")
```

### Pattern 3: File-Based (agent writes JSON, dashboard reads it)

```python
# Agent writes data file
write("~/.openclaw/canvas/data.json", json.dumps(metrics))

# Dashboard HTML fetches it
# setInterval(() => fetch('data.json').then(r => r.json()).then(render), 5000);
```

---

## Best Practices

1. **Dark themes always.** Bright screens in ambient settings are hostile. Use `#0d1117` or darker backgrounds.

2. **Large fonts.** If it's going on a TV across the room, minimum effective font size is `clamp(1rem, 1.5vw, 1.2rem)`. Headlines should be `3vw+`.

3. **No scrolling.** Everything must fit on one screen. If you have too much data, paginate with auto-rotation, don't scroll.

4. **No external dependencies.** CDN-loaded libraries break when the network hiccups. Pure HTML/CSS/JS only.

5. **Graceful degradation.** If a fetch fails, show the last good data with a "stale" indicator. Never show a blank screen or error stack trace.

6. **Viewport units.** Use `vw`/`vh` and `clamp()` for sizing. The dashboard might show on a 720p tablet or a 4K TV.

7. **Minimal animation.** Subtle transitions are fine. Anything that draws the eye constantly is distracting for ambient displays.

8. **Test with snapshot.** After pushing, always `canvas(action="snapshot")` to verify it looks right.

---

## Node Targeting

Target specific displays by node name:

```python
# Living room TV — ambient display
canvas(action="present", node="living-room", url=".../ambient.html")

# Office monitor — status board
canvas(action="present", node="office-monitor", url=".../status.html")

# Meeting room tablet — metrics
canvas(action="present", node="meeting-room", url=".../metrics.html")
```

List available nodes:

```python
nodes(action="status")  # Shows all connected nodes
```

---

## Quick Start

Fastest path to a dashboard on a display:

```python
# 1. Write the ambient clock to canvas
write("~/.openclaw/canvas/clock.html", AMBIENT_TEMPLATE_HTML)

# 2. Push to a display
canvas(action="present", node="living-room")

# 3. Navigate to the file
canvas(action="navigate", node="living-room", url="http://localhost:18789/__openclaw__/canvas/clock.html")

# 4. Verify
canvas(action="snapshot", node="living-room")
```

Done. You have a live dashboard on a TV.
