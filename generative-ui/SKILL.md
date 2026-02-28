# Generative UI

> **What:** Dynamically generate and push live HTML/CSS/JS interfaces to OpenClaw canvas display surfaces. Transform arbitrary data (JSON metrics, events, lists) into polished, real-time UIs.
>
> **When to use:** Live dashboards, ambient TV displays, data walls, notification feeds, project trackers, system monitors — any scenario where you need to compose UI on the fly from dynamic data.
>
> **Difference from canvas-dashboard:** That skill provides static templates. This skill teaches you to **generate** UIs programmatically from data.

---

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Component Library](#component-library)
3. [Design System](#design-system)
4. [A2UI Protocol Integration](#a2ui-protocol-integration)
5. [Live Update Patterns](#live-update-patterns)
6. [TV/Ambient Display Infrastructure](#tvambient-display-infrastructure)
7. [Data-Driven Generation Workflow](#data-driven-generation-workflow)
8. [Error Handling](#error-handling)
9. [TV-Distance Readability](#tv-distance-readability)
10. [Complete Examples](#complete-examples)

---

## Core Concepts

### What Is Generative UI?

Traditional approach:
- Write a template HTML file
- Fill in placeholders
- Push to canvas

Generative approach:
- Receive arbitrary data (API response, database query, event stream)
- Analyze structure and content
- Select appropriate components
- Compose HTML dynamically
- Apply design system
- Push to canvas
- Update surgically without full reload

### The Canvas Display Model

OpenClaw canvas nodes are **persistent web views** connected to your Gateway:

```
┌─────────────────┐
│   Agent/LLM     │
│  (generates UI) │
└────────┬────────┘
         │
         │ writes HTML / sends A2UI
         ▼
┌─────────────────┐
│  OpenClaw GW    │
│  Port 18789     │
└────────┬────────┘
         │
         │ serves files / relays messages
         ▼
┌─────────────────┐
│  Canvas Node    │
│ (TV/tablet/Mac) │
│  Chromium view  │
└─────────────────┘
```

**Key insight:** The display is **always on**. You don't reload the page — you update it.

---

## Component Library

Copy-paste these components into your generated HTML. Each is self-contained, dark-themed, and TV-optimized.

### 1. Stat Card

A prominent metric with label, value, and optional trend indicator.

```html
<div class="stat-card">
  <div class="stat-label">Active Users</div>
  <div class="stat-value">1,247</div>
  <div class="stat-trend positive">+12%</div>
</div>

<style>
.stat-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: clamp(1.2rem, 2vw, 2rem);
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.stat-label {
  font-size: clamp(0.85rem, 1.1vw, 1rem);
  text-transform: uppercase;
  letter-spacing: 0.08em;
  opacity: 0.6;
  font-weight: 500;
}

.stat-value {
  font-size: clamp(2rem, 4vw, 3.5rem);
  font-weight: 700;
  line-height: 1;
  color: var(--text-primary);
}

.stat-trend {
  font-size: clamp(0.9rem, 1.2vw, 1.1rem);
  font-weight: 600;
}

.stat-trend.positive { color: var(--success); }
.stat-trend.negative { color: var(--error); }
</style>
```

**When to use:** Dashboard KPIs, single prominent metrics, comparison values.

---

### 2. Status Row

A labeled item with status indicator and optional secondary text.

```html
<div class="status-row">
  <div class="status-indicator status-ok"></div>
  <div class="status-content">
    <div class="status-primary">API Gateway</div>
    <div class="status-secondary">Healthy · 127ms avg</div>
  </div>
  <div class="status-badge">99.9%</div>
</div>

<style>
.status-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: clamp(0.8rem, 1.5vw, 1.2rem);
  border-bottom: 1px solid var(--border);
  font-size: clamp(0.95rem, 1.3vw, 1.15rem);
}

.status-row:last-child {
  border-bottom: none;
}

.status-indicator {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  flex-shrink: 0;
}

.status-ok {
  background: var(--success);
  box-shadow: 0 0 8px var(--success-glow);
}

.status-warning {
  background: var(--warning);
  box-shadow: 0 0 8px var(--warning-glow);
}

.status-error {
  background: var(--error);
  box-shadow: 0 0 8px var(--error-glow);
}

.status-neutral {
  background: var(--text-tertiary);
}

.status-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.status-primary {
  font-weight: 500;
  color: var(--text-primary);
}

.status-secondary {
  font-size: 0.9em;
  opacity: 0.6;
}

.status-badge {
  font-size: 0.9em;
  padding: 0.25em 0.6em;
  background: var(--surface-elevated);
  border-radius: 6px;
  font-weight: 600;
}
</style>
```

**When to use:** Service health lists, connection status, checklist items, event logs.

---

### 3. Progress Ring

Circular progress indicator with percentage text.

```html
<div class="progress-ring-container">
  <svg class="progress-ring" viewBox="0 0 120 120">
    <circle class="progress-ring-bg" cx="60" cy="60" r="52" />
    <circle class="progress-ring-fill" cx="60" cy="60" r="52" 
            stroke-dasharray="326.73" 
            stroke-dashoffset="98.02" />
  </svg>
  <div class="progress-ring-text">70%</div>
</div>

<style>
.progress-ring-container {
  position: relative;
  width: clamp(80px, 12vw, 120px);
  height: clamp(80px, 12vw, 120px);
}

.progress-ring {
  width: 100%;
  height: 100%;
  transform: rotate(-90deg);
}

.progress-ring-bg {
  fill: none;
  stroke: var(--surface-elevated);
  stroke-width: 8;
}

.progress-ring-fill {
  fill: none;
  stroke: var(--accent);
  stroke-width: 8;
  stroke-linecap: round;
  transition: stroke-dashoffset 0.6s ease;
}

.progress-ring-text {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: clamp(1.2rem, 2vw, 1.8rem);
  font-weight: 700;
  color: var(--text-primary);
}
</style>

<script>
// Calculate stroke-dashoffset: circumference * (1 - percentage)
// Circumference = 2 * π * r = 2 * 3.14159 * 52 ≈ 326.73
function setProgress(percentage) {
  const circumference = 326.73;
  const offset = circumference * (1 - percentage / 100);
  document.querySelector('.progress-ring-fill').style.strokeDashoffset = offset;
  document.querySelector('.progress-ring-text').textContent = percentage + '%';
}
</script>
```

**When to use:** Task completion, loading states, quota usage, health scores.

---

### 4. Data Table

Minimal, readable table for structured data.

```html
<table class="data-table">
  <thead>
    <tr>
      <th>Project</th>
      <th>Status</th>
      <th>Progress</th>
      <th>Due</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Otto Canvas</strong></td>
      <td><span class="badge badge-success">Active</span></td>
      <td>78%</td>
      <td>Mar 15</td>
    </tr>
    <tr>
      <td><strong>Stellar v2</strong></td>
      <td><span class="badge badge-warning">Review</span></td>
      <td>92%</td>
      <td>Mar 8</td>
    </tr>
  </tbody>
</table>

<style>
.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: clamp(0.9rem, 1.2vw, 1.05rem);
}

.data-table th {
  text-align: left;
  padding: clamp(0.6rem, 1vw, 0.9rem);
  border-bottom: 2px solid var(--border);
  font-size: 0.85em;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  opacity: 0.6;
  font-weight: 600;
}

.data-table td {
  padding: clamp(0.7rem, 1.2vw, 1rem);
  border-bottom: 1px solid var(--border-subtle);
}

.data-table tbody tr:last-child td {
  border-bottom: none;
}

.data-table tbody tr:hover {
  background: var(--surface-hover);
}

.badge {
  display: inline-block;
  padding: 0.25em 0.6em;
  border-radius: 6px;
  font-size: 0.85em;
  font-weight: 600;
}

.badge-success {
  background: var(--success-surface);
  color: var(--success);
}

.badge-warning {
  background: var(--warning-surface);
  color: var(--warning);
}

.badge-error {
  background: var(--error-surface);
  color: var(--error);
}
</style>
```

**When to use:** Lists with multiple attributes, comparison tables, logs, transaction history.

---

### 5. Notification Toast

Temporary or persistent notification banner.

```html
<div class="toast toast-info">
  <div class="toast-icon">ℹ️</div>
  <div class="toast-content">
    <div class="toast-title">Deployment Started</div>
    <div class="toast-body">Building production bundle...</div>
  </div>
  <button class="toast-dismiss" onclick="this.parentElement.remove()">×</button>
</div>

<style>
.toast {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: clamp(0.9rem, 1.5vw, 1.2rem);
  border-radius: 12px;
  border-left: 4px solid;
  background: var(--surface);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  font-size: clamp(0.9rem, 1.2vw, 1.05rem);
}

.toast-info {
  border-left-color: var(--info);
  background: var(--info-surface);
}

.toast-success {
  border-left-color: var(--success);
  background: var(--success-surface);
}

.toast-warning {
  border-left-color: var(--warning);
  background: var(--warning-surface);
}

.toast-error {
  border-left-color: var(--error);
  background: var(--error-surface);
}

.toast-icon {
  font-size: 1.5em;
  flex-shrink: 0;
}

.toast-content {
  flex: 1;
}

.toast-title {
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.toast-body {
  opacity: 0.8;
  font-size: 0.9em;
}

.toast-dismiss {
  background: none;
  border: none;
  color: var(--text-tertiary);
  font-size: 1.8em;
  cursor: pointer;
  padding: 0;
  width: 1.2em;
  height: 1.2em;
  line-height: 1;
  flex-shrink: 0;
  transition: color 0.2s ease;
}

.toast-dismiss:hover {
  color: var(--text-primary);
}
</style>
```

**When to use:** Build status, deployment notifications, error alerts, system messages.

---

### 6. Timeline

Vertical event timeline with timestamps.

```html
<div class="timeline">
  <div class="timeline-item">
    <div class="timeline-marker timeline-marker-success"></div>
    <div class="timeline-content">
      <div class="timeline-time">2:45 PM</div>
      <div class="timeline-title">Deployment Successful</div>
      <div class="timeline-body">Production build completed in 2m 14s</div>
    </div>
  </div>
  <div class="timeline-item">
    <div class="timeline-marker timeline-marker-info"></div>
    <div class="timeline-content">
      <div class="timeline-time">2:43 PM</div>
      <div class="timeline-title">Build Started</div>
      <div class="timeline-body">Triggered by push to main branch</div>
    </div>
  </div>
</div>

<style>
.timeline {
  position: relative;
  padding-left: 2rem;
}

.timeline::before {
  content: '';
  position: absolute;
  left: 6px;
  top: 0;
  bottom: 0;
  width: 2px;
  background: var(--border);
}

.timeline-item {
  position: relative;
  padding-bottom: clamp(1.2rem, 2vw, 1.8rem);
}

.timeline-item:last-child {
  padding-bottom: 0;
}

.timeline-marker {
  position: absolute;
  left: -2rem;
  top: 0.3rem;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  border: 2px solid var(--background);
  z-index: 1;
}

.timeline-marker-success { background: var(--success); }
.timeline-marker-info { background: var(--info); }
.timeline-marker-warning { background: var(--warning); }
.timeline-marker-error { background: var(--error); }

.timeline-content {
  font-size: clamp(0.9rem, 1.2vw, 1.05rem);
}

.timeline-time {
  font-size: 0.85em;
  opacity: 0.5;
  margin-bottom: 0.25rem;
}

.timeline-title {
  font-weight: 600;
  margin-bottom: 0.25rem;
  color: var(--text-primary);
}

.timeline-body {
  opacity: 0.7;
  font-size: 0.95em;
}
</style>
```

**When to use:** Activity feeds, build logs, event streams, deployment history.

---

### 7. Sparkline

Inline miniature chart for trends.

```html
<div class="sparkline-container">
  <svg class="sparkline" viewBox="0 0 100 30" preserveAspectRatio="none">
    <polyline
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      points="0,20 10,18 20,22 30,15 40,17 50,12 60,14 70,8 80,10 90,6 100,4"
    />
  </svg>
</div>

<style>
.sparkline-container {
  display: inline-block;
  width: clamp(60px, 10vw, 100px);
  height: clamp(20px, 3vw, 30px);
  color: var(--accent);
}

.sparkline {
  width: 100%;
  height: 100%;
  display: block;
}
</style>

<script>
// Generate sparkline points from data array
function generateSparkline(data) {
  const max = Math.max(...data);
  const min = Math.min(...data);
  const range = max - min || 1;
  
  const points = data.map((value, index) => {
    const x = (index / (data.length - 1)) * 100;
    const y = 30 - ((value - min) / range) * 30;
    return `${x},${y}`;
  }).join(' ');
  
  return `<svg class="sparkline" viewBox="0 0 100 30" preserveAspectRatio="none">
    <polyline fill="none" stroke="currentColor" stroke-width="2" points="${points}" />
  </svg>`;
}
</script>
```

**When to use:** Inline metrics trends, quick visual indicators, historical data preview.

---

### 8. Progress Bar

Horizontal progress indicator with label.

```html
<div class="progress-bar-container">
  <div class="progress-bar-header">
    <span class="progress-bar-label">Build Progress</span>
    <span class="progress-bar-value">67%</span>
  </div>
  <div class="progress-bar-track">
    <div class="progress-bar-fill" style="width: 67%"></div>
  </div>
</div>

<style>
.progress-bar-container {
  width: 100%;
}

.progress-bar-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
  font-size: clamp(0.85rem, 1.1vw, 1rem);
}

.progress-bar-label {
  font-weight: 500;
}

.progress-bar-value {
  font-weight: 700;
  color: var(--accent);
}

.progress-bar-track {
  height: clamp(8px, 1.2vw, 12px);
  background: var(--surface-elevated);
  border-radius: 6px;
  overflow: hidden;
}

.progress-bar-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--accent), var(--accent-bright));
  border-radius: 6px;
  transition: width 0.6s ease;
}
</style>
```

**When to use:** Task completion, upload/download progress, quota usage, multi-step processes.

---

## Design System

### CSS Custom Properties

Use these variables in all generated HTML for consistency:

```css
:root {
  /* Colors */
  --background: #0d1117;
  --surface: #161b22;
  --surface-elevated: #21262d;
  --surface-hover: #30363d;
  --border: #30363d;
  --border-subtle: #21262d;
  
  /* Text */
  --text-primary: #e6edf3;
  --text-secondary: #c9d1d9;
  --text-tertiary: #7d8590;
  
  /* Semantic */
  --success: #3fb950;
  --success-glow: rgba(63, 185, 80, 0.4);
  --success-surface: rgba(63, 185, 80, 0.1);
  
  --warning: #d29922;
  --warning-glow: rgba(210, 153, 34, 0.4);
  --warning-surface: rgba(210, 153, 34, 0.1);
  
  --error: #f85149;
  --error-glow: rgba(248, 81, 73, 0.4);
  --error-surface: rgba(248, 81, 73, 0.1);
  
  --info: #58a6ff;
  --info-glow: rgba(88, 166, 255, 0.4);
  --info-surface: rgba(88, 166, 255, 0.1);
  
  --accent: #58a6ff;
  --accent-bright: #79c0ff;
  
  /* Typography Scale */
  --text-xs: clamp(0.75rem, 1vw, 0.85rem);
  --text-sm: clamp(0.85rem, 1.1vw, 0.95rem);
  --text-base: clamp(0.95rem, 1.3vw, 1.1rem);
  --text-lg: clamp(1.1rem, 1.5vw, 1.3rem);
  --text-xl: clamp(1.3rem, 2vw, 1.6rem);
  --text-2xl: clamp(1.6rem, 2.5vw, 2rem);
  --text-3xl: clamp(2rem, 3.5vw, 2.8rem);
  --text-4xl: clamp(2.5rem, 4.5vw, 3.5rem);
  
  /* Spacing Scale */
  --space-xs: clamp(0.25rem, 0.5vw, 0.5rem);
  --space-sm: clamp(0.5rem, 1vw, 0.75rem);
  --space-md: clamp(0.75rem, 1.5vw, 1rem);
  --space-lg: clamp(1rem, 2vw, 1.5rem);
  --space-xl: clamp(1.5rem, 3vw, 2rem);
  --space-2xl: clamp(2rem, 4vw, 3rem);
}
```

### Base Reset

Include this in every generated HTML:

```css
*, *::before, *::after {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  min-height: 100vh;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
  background: var(--background);
  color: var(--text-secondary);
  padding: clamp(1.5rem, 3vw, 2.5rem);
  overflow-x: hidden;
}
```

### Grid Layouts

Responsive grid system for component composition:

```css
/* Auto-fit grid (equal-width columns) */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--space-lg);
}

/* Fixed columns at different breakpoints */
.grid-2 {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-lg);
}

@media (min-width: 768px) {
  .grid-2 { grid-template-columns: repeat(2, 1fr); }
}

@media (min-width: 1200px) {
  .grid-3 { grid-template-columns: repeat(3, 1fr); }
  .grid-4 { grid-template-columns: repeat(4, 1fr); }
}

/* Sidebar layout */
.layout-sidebar {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-lg);
}

@media (min-width: 1024px) {
  .layout-sidebar {
    grid-template-columns: 320px 1fr;
  }
}
```

### Typography Scale

```css
.text-xs { font-size: var(--text-xs); }
.text-sm { font-size: var(--text-sm); }
.text-base { font-size: var(--text-base); }
.text-lg { font-size: var(--text-lg); }
.text-xl { font-size: var(--text-xl); }
.text-2xl { font-size: var(--text-2xl); }
.text-3xl { font-size: var(--text-3xl); }
.text-4xl { font-size: var(--text-4xl); }

.font-normal { font-weight: 400; }
.font-medium { font-weight: 500; }
.font-semibold { font-weight: 600; }
.font-bold { font-weight: 700; }

.uppercase {
  text-transform: uppercase;
  letter-spacing: 0.08em;
}
```

---

## A2UI Protocol Integration

**A2UI (Agent-to-UI)** is OpenClaw's protocol for pushing structured UI updates without writing HTML files. Use it for real-time updates to already-displayed interfaces.

### A2UI v0.8 Message Format

A2UI messages are **JSONL** (newline-delimited JSON) sent to the Gateway's A2UI endpoint.

**Base message structure:**

```json
{
  "type": "surfaceUpdate",
  "surfaceId": "main-display",
  "targetNode": "office-tv",
  "timestamp": "2026-02-28T02:30:00Z",
  "payload": { ... }
}
```

### Message Types

#### 1. `beginRendering` — Initialize a display surface

Clears the surface and prepares for updates.

```json
{
  "type": "beginRendering",
  "surfaceId": "dashboard-main",
  "targetNode": "living-room",
  "timestamp": "2026-02-28T02:30:00Z",
  "payload": {
    "clearExisting": true,
    "backgroundColor": "#0d1117",
    "title": "System Dashboard"
  }
}
```

**When to use:** First message when starting a new UI session, or when completely resetting a display.

---

#### 2. `surfaceUpdate` — Update surface content

Push HTML fragments or data updates to specific regions.

```json
{
  "type": "surfaceUpdate",
  "surfaceId": "dashboard-main",
  "targetNode": "living-room",
  "timestamp": "2026-02-28T02:30:15Z",
  "payload": {
    "updateType": "innerHTML",
    "targetSelector": "#stats-panel",
    "content": "<div class=\"stat-card\"><div class=\"stat-label\">CPU Usage</div><div class=\"stat-value\">42%</div></div>"
  }
}
```

**Update types:**

| Type | Description | Example |
|------|-------------|---------|
| `innerHTML` | Replace element content | Update a metric value |
| `outerHTML` | Replace entire element | Swap component |
| `append` | Add to end of container | Add event to feed |
| `prepend` | Add to start of container | Insert notification at top |
| `setAttribute` | Change element attribute | Update `data-*` attribute |
| `setStyle` | Change CSS property | Animate color change |

---

#### 3. `dataUpdate` — Send structured data

Push data that the frontend JavaScript consumes.

```json
{
  "type": "dataUpdate",
  "surfaceId": "dashboard-main",
  "targetNode": "living-room",
  "timestamp": "2026-02-28T02:30:30Z",
  "payload": {
    "dataKey": "system-metrics",
    "data": {
      "cpu": 42,
      "memory": 67,
      "disk": 81,
      "network": 12.4
    }
  }
}
```

The frontend listens for these updates:

```javascript
window.addEventListener('a2ui-data', (event) => {
  const { dataKey, data } = event.detail;
  if (dataKey === 'system-metrics') {
    updateMetrics(data);
  }
});
```

---

### Sending A2UI Messages

**Method 1: Write to Gateway's A2UI directory**

```python
import json
from datetime import datetime

message = {
    "type": "surfaceUpdate",
    "surfaceId": "dashboard",
    "targetNode": "office-tv",
    "timestamp": datetime.utcnow().isoformat() + "Z",
    "payload": {
        "updateType": "innerHTML",
        "targetSelector": "#cpu-metric",
        "content": "<div class=\"stat-value\">38%</div>"
    }
}

# Write as JSONL
with open("~/.openclaw/a2ui/updates.jsonl", "a") as f:
    f.write(json.dumps(message) + "\n")
```

**Method 2: HTTP POST to Gateway**

```bash
curl -X POST http://localhost:18789/__openclaw__/a2ui \
  -H "Content-Type: application/json" \
  -d '{
    "type": "surfaceUpdate",
    "surfaceId": "dashboard",
    "targetNode": "office-tv",
    "timestamp": "2026-02-28T02:30:00Z",
    "payload": {
      "updateType": "innerHTML",
      "targetSelector": "#status",
      "content": "<span class=\"badge badge-success\">Healthy</span>"
    }
  }'
```

**Method 3: Via OpenClaw tool (if available)**

```python
a2ui(
    action="update",
    surfaceId="dashboard",
    node="office-tv",
    targetSelector="#metrics",
    content="<div>Updated content</div>"
)
```

---

### Frontend A2UI Receiver

Include this JavaScript in your generated HTML to handle A2UI messages:

```javascript
<script>
// A2UI message receiver
(function() {
  const ws = new WebSocket('ws://localhost:18789/__openclaw__/a2ui/stream');
  
  ws.onmessage = (event) => {
    try {
      const message = JSON.parse(event.data);
      
      if (message.type === 'surfaceUpdate') {
        handleSurfaceUpdate(message.payload);
      } else if (message.type === 'dataUpdate') {
        handleDataUpdate(message.payload);
      }
    } catch (error) {
      console.error('A2UI parse error:', error);
    }
  };
  
  function handleSurfaceUpdate(payload) {
    const target = document.querySelector(payload.targetSelector);
    if (!target) return;
    
    switch (payload.updateType) {
      case 'innerHTML':
        target.innerHTML = payload.content;
        break;
      case 'outerHTML':
        target.outerHTML = payload.content;
        break;
      case 'append':
        target.insertAdjacentHTML('beforeend', payload.content);
        break;
      case 'prepend':
        target.insertAdjacentHTML('afterbegin', payload.content);
        break;
      case 'setAttribute':
        target.setAttribute(payload.attribute, payload.value);
        break;
      case 'setStyle':
        target.style[payload.property] = payload.value;
        break;
    }
  }
  
  function handleDataUpdate(payload) {
    const event = new CustomEvent('a2ui-data', {
      detail: {
        dataKey: payload.dataKey,
        data: payload.data
      }
    });
    window.dispatchEvent(event);
  }
  
  ws.onerror = (error) => console.error('A2UI connection error:', error);
  ws.onclose = () => setTimeout(() => location.reload(), 5000); // Reconnect
})();
</script>
```

---

## Live Update Patterns

Choose the right update strategy based on your use case.

### Pattern 1: Full-Page Regeneration

**When to use:** Data structure changes significantly, complete UI refresh needed, initial render.

**How it works:**
1. Generate complete HTML from data
2. Write to canvas directory
3. Navigate canvas to new file (or reload if same file)

**Example:**

```python
def render_dashboard(data):
    html = f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Dashboard</title>
        <style>{get_design_system()}</style>
    </head>
    <body>
        {generate_components(data)}
    </body>
    </html>
    """
    
    write("~/.openclaw/canvas/dashboard.html", html)
    canvas(action="navigate", node="office-tv", 
           url="http://localhost:18789/__openclaw__/canvas/dashboard.html")
```

**Pros:** Simple, clean state, works for any change
**Cons:** Flicker, loses scroll position, resets animations

---

### Pattern 2: Surgical Eval Updates

**When to use:** Small, frequent updates to specific elements; real-time metrics; countdown timers.

**How it works:**
1. Generate minimal HTML/JS snippet
2. Use `canvas(action="eval")` to run on display
3. Updates DOM without reload

**Example:**

```python
def update_cpu_metric(value):
    js = f"""
    document.querySelector('#cpu-value').textContent = '{value}%';
    document.querySelector('#cpu-bar').style.width = '{value}%';
    """
    canvas(action="eval", node="office-tv", javaScript=js)

# Update every 5 seconds
while True:
    cpu = get_cpu_usage()
    update_cpu_metric(cpu)
    time.sleep(5)
```

**Pros:** No flicker, fast, maintains state
**Cons:** Requires stable selectors, can't add new elements easily

---

### Pattern 3: A2UI Surface Updates

**When to use:** Complex real-time apps, multi-agent collaboration, event-driven UIs, live feeds.

**How it works:**
1. Frontend establishes WebSocket connection
2. Agent sends structured updates via A2UI protocol
3. Frontend receives and applies updates

**Example:**

```python
def push_event_to_feed(event):
    message = {
        "type": "surfaceUpdate",
        "surfaceId": "event-feed",
        "targetNode": "office-tv",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "payload": {
            "updateType": "prepend",
            "targetSelector": "#events-list",
            "content": f"""
            <div class="timeline-item">
                <div class="timeline-marker timeline-marker-info"></div>
                <div class="timeline-content">
                    <div class="timeline-time">{event['time']}</div>
                    <div class="timeline-title">{event['title']}</div>
                    <div class="timeline-body">{event['body']}</div>
                </div>
            </div>
            """
        }
    }
    
    send_a2ui_message(message)
```

**Pros:** Real-time, efficient, scalable, no DOM querying needed
**Cons:** Requires WebSocket setup, more complex architecture

---

### Decision Matrix

| Scenario | Pattern | Why |
|----------|---------|-----|
| Initial render | Full-page | Clean slate |
| Data structure change (e.g., new columns) | Full-page | Layout needs rebuild |
| Update 1-3 metrics every few seconds | Surgical eval | Fast, simple |
| Live event feed (HN, logs, notifications) | A2UI | Streaming updates |
| Multi-agent dashboard (agents push updates) | A2UI | Decoupled updates |
| Countdown timer | Surgical eval | Frequent, predictable |
| Real-time chart data | A2UI + data events | Separation of concerns |

---

## TV/Ambient Display Infrastructure

### Setting Up a Canvas Node

**Option 1: Dedicated Mac Mini**

1. Connect Mac mini to TV via HDMI
2. Install OpenClaw Gateway: `openclaw gateway install`
3. Configure as node:
   ```bash
   openclaw node register --name "living-room" --type "canvas"
   ```
4. Enable kiosk mode (prevent sleep, hide cursor):
   ```bash
   # Disable sleep
   sudo pmset -a displaysleep 0
   sudo pmset -a sleep 0
   
   # Hide cursor after 3 seconds
   defaults write NSGlobalDomain NSDisableAutomaticTermination -bool TRUE
   ```

5. Launch browser in kiosk mode (run on login):
   ```bash
   # ~/Library/LaunchAgents/com.openclaw.canvas.plist
   /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
     --kiosk \
     --noerrdialogs \
     --disable-infobars \
     --disable-session-crashed-bubble \
     "http://localhost:18789/__openclaw__/canvas/default.html"
   ```

---

**Option 2: iPad/Tablet**

1. Install OpenClaw app (if available) or use Guided Access mode
2. Pair with Gateway:
   ```bash
   openclaw node pair --device "ipad-kitchen" --pin 123456
   ```
3. Enable Guided Access (Settings → Accessibility → Guided Access)
4. Open Safari to canvas URL, triple-click Home to lock

---

**Option 3: Raspberry Pi**

1. Install Raspberry Pi OS Lite
2. Install Chromium: `sudo apt-get install chromium-browser`
3. Install OpenClaw node agent:
   ```bash
   curl -fsSL https://openclaw.dev/install-node.sh | bash
   openclaw node register --name "garage-display" --type "canvas"
   ```
4. Configure X11 kiosk mode:
   ```bash
   # ~/.xinitrc
   #!/bin/bash
   xset s off
   xset -dpms
   xset s noblank
   chromium-browser --kiosk --noerrdialogs --disable-infobars \
     http://<gateway-ip>:18789/__openclaw__/canvas/default.html
   ```

---

### Node Discovery

List available canvas nodes:

```python
# Via OpenClaw tool
nodes = canvas(action="list-nodes")

# Returns:
# [
#   {"id": "living-room", "type": "canvas", "status": "online", "resolution": "1920x1080"},
#   {"id": "office-tv", "type": "canvas", "status": "online", "resolution": "3840x2160"},
#   {"id": "kitchen-ipad", "type": "canvas", "status": "offline"}
# ]
```

---

### Maintaining the Display

**Heartbeat pattern:** Keep display alive and recover from disconnects.

```python
def maintain_display(node_name, generate_func):
    """
    Keep a display updated throughout the day.
    
    Args:
        node_name: Canvas node identifier
        generate_func: Function that returns HTML string
    """
    last_render_time = 0
    last_health_check = 0
    
    while True:
        now = time.time()
        
        # Health check every 60 seconds
        if now - last_health_check > 60:
            try:
                status = canvas(action="snapshot", node=node_name)
                if not status or 'error' in status:
                    # Node offline or render failed, try to recover
                    print(f"Health check failed for {node_name}, re-rendering...")
                    force_render = True
                else:
                    force_render = False
            except Exception as e:
                print(f"Health check error: {e}")
                force_render = True
            
            last_health_check = now
        
        # Re-render every 5 minutes or on health failure
        if force_render or now - last_render_time > 300:
            try:
                html = generate_func()
                filename = f"{node_name}-display.html"
                write(f"~/.openclaw/canvas/{filename}", html)
                
                canvas(
                    action="present",
                    node=node_name,
                    url=f"http://localhost:18789/__openclaw__/canvas/{filename}"
                )
                
                last_render_time = now
                print(f"Rendered {node_name} at {datetime.now()}")
                
            except Exception as e:
                print(f"Render error: {e}")
        
        time.sleep(10)  # Check every 10 seconds
```

**Usage:**

```python
def generate_system_dashboard():
    metrics = get_system_metrics()
    return build_dashboard_html(metrics)

# Run as background task
maintain_display("office-tv", generate_system_dashboard)
```

---

### Multi-Display Orchestration

Manage multiple displays with different content:

```python
displays = {
    "living-room": {
        "generator": generate_news_feed,
        "refresh_interval": 300,  # 5 minutes
    },
    "office-tv": {
        "generator": generate_project_tracker,
        "refresh_interval": 60,  # 1 minute
    },
    "kitchen-ipad": {
        "generator": generate_family_calendar,
        "refresh_interval": 600,  # 10 minutes
    }
}

def orchestrate_displays():
    threads = []
    for node_name, config in displays.items():
        thread = threading.Thread(
            target=maintain_display,
            args=(node_name, config["generator"]),
            daemon=True
        )
        thread.start()
        threads.append(thread)
    
    # Keep main thread alive
    for thread in threads:
        thread.join()
```

---

## Data-Driven Generation Workflow

The core pattern for generative UI.

### Step-by-Step Workflow

```
1. Receive Data
   ↓
2. Analyze Structure
   ↓
3. Select Layout & Components
   ↓
4. Generate HTML
   ↓
5. Write to Canvas Directory
   ↓
6. Push to Display
   ↓
7. Snapshot to Verify
   ↓
8. Update Surgically (if needed)
```

### Example: GitHub Repo Activity Dashboard

```python
def generate_repo_dashboard(repo_data):
    """
    Generate a dashboard from GitHub API data.
    
    Args:
        repo_data: Dict with keys: name, stars, forks, issues, recent_commits, contributors
    """
    
    # STEP 1: Receive Data (already have repo_data)
    
    # STEP 2: Analyze Structure
    has_commits = len(repo_data.get('recent_commits', [])) > 0
    has_issues = repo_data.get('issues', 0) > 0
    
    # STEP 3: Select Layout & Components
    # Top: Stat cards (stars, forks, issues)
    # Middle: Recent commits timeline
    # Bottom: Top contributors table
    
    # STEP 4: Generate HTML
    
    # Header
    html = f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>{repo_data['name']} Activity</title>
        <style>
            {get_design_system()}
            {get_component_styles()}
        </style>
    </head>
    <body>
        <header>
            <h1>{repo_data['name']}</h1>
            <div class="meta">Last updated: {datetime.now().strftime('%I:%M %p')}</div>
        </header>
    """
    
    # Stats grid
    html += '<div class="grid grid-3" style="margin-bottom: 2rem;">'
    
    stats = [
        ('Stars', repo_data['stars'], '+' + str(repo_data.get('stars_delta', 0))),
        ('Forks', repo_data['forks'], ''),
        ('Open Issues', repo_data['issues'], '')
    ]
    
    for label, value, trend in stats:
        html += f"""
        <div class="stat-card">
            <div class="stat-label">{label}</div>
            <div class="stat-value">{value:,}</div>
            {f'<div class="stat-trend positive">{trend}</div>' if trend else ''}
        </div>
        """
    
    html += '</div>'
    
    # Recent commits timeline
    if has_commits:
        html += '<div class="card" style="margin-bottom: 2rem;"><h2>Recent Commits</h2><div class="timeline">'
        
        for commit in repo_data['recent_commits'][:5]:
            html += f"""
            <div class="timeline-item">
                <div class="timeline-marker timeline-marker-info"></div>
                <div class="timeline-content">
                    <div class="timeline-time">{commit['time_ago']}</div>
                    <div class="timeline-title">{commit['message']}</div>
                    <div class="timeline-body">{commit['author']} · {commit['sha'][:7]}</div>
                </div>
            </div>
            """
        
        html += '</div></div>'
    
    # Contributors table
    if repo_data.get('contributors'):
        html += '<div class="card"><h2>Top Contributors</h2><table class="data-table"><thead><tr><th>Name</th><th>Commits</th><th>Additions</th><th>Deletions</th></tr></thead><tbody>'
        
        for contributor in repo_data['contributors'][:5]:
            html += f"""
            <tr>
                <td><strong>{contributor['name']}</strong></td>
                <td>{contributor['commits']}</td>
                <td style="color: var(--success)">{contributor['additions']:,}</td>
                <td style="color: var(--error)">{contributor['deletions']:,}</td>
            </tr>
            """
        
        html += '</tbody></table></div>'
    
    html += '</body></html>'
    
    # STEP 5: Write to Canvas Directory
    filepath = "~/.openclaw/canvas/repo-dashboard.html"
    write(filepath, html)
    
    # STEP 6: Push to Display
    canvas(
        action="present",
        node="office-tv",
        url="http://localhost:18789/__openclaw__/canvas/repo-dashboard.html"
    )
    
    # STEP 7: Snapshot to Verify
    snapshot = canvas(action="snapshot", node="office-tv")
    
    if snapshot and 'error' not in snapshot:
        print("✓ Dashboard rendered successfully")
        
        # STEP 8: Update Surgically (if needed)
        # For real-time star count updates every minute:
        schedule_surgical_update(
            node="office-tv",
            selector="#stars-value",
            data_source=lambda: get_star_count(repo_data['name']),
            interval=60
        )
    else:
        print("✗ Render failed:", snapshot.get('error'))
    
    return html
```

### Helper Functions

```python
def get_design_system():
    """Returns CSS custom properties and base reset."""
    return """
    :root {
        --background: #0d1117;
        --surface: #161b22;
        --surface-elevated: #21262d;
        --border: #30363d;
        --text-primary: #e6edf3;
        --text-secondary: #c9d1d9;
        --success: #3fb950;
        --error: #f85149;
        --info: #58a6ff;
        --accent: #58a6ff;
    }
    
    *, *::before, *::after {
        margin: 0; padding: 0; box-sizing: border-box;
    }
    
    body {
        min-height: 100vh;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
        background: var(--background);
        color: var(--text-secondary);
        padding: clamp(1.5rem, 3vw, 2.5rem);
    }
    
    header {
        margin-bottom: 2rem;
    }
    
    header h1 {
        font-size: clamp(1.8rem, 3vw, 2.5rem);
        color: var(--text-primary);
        font-weight: 700;
    }
    
    header .meta {
        opacity: 0.5;
        margin-top: 0.5rem;
    }
    """

def get_component_styles():
    """Returns styles for all components (stat-card, timeline, table, etc)."""
    # Return the full CSS from the Component Library section
    pass
```

---

## Error Handling

### Common Failure Modes

| Error | Cause | Detection | Recovery |
|-------|-------|-----------|----------|
| Canvas offline | Node disconnected, network issue | Snapshot returns error | Wait and retry, show fallback on other display |
| Render failure | Malformed HTML, JS error | Snapshot shows blank/error | Regenerate with error recovery, validate HTML |
| WebSocket disconnect | Gateway restart, network | A2UI messages not received | Reconnect with exponential backoff |
| File write failure | Disk full, permissions | Write operation fails | Clear old files, check permissions |
| Eval failure | Invalid JavaScript syntax | Eval returns error | Validate JS before sending |

---

### Error Recovery Patterns

**Pattern 1: Retry with Exponential Backoff**

```python
def push_to_canvas_with_retry(node, html, max_retries=3):
    for attempt in range(max_retries):
        try:
            filename = f"{node}-display.html"
            write(f"~/.openclaw/canvas/{filename}", html)
            
            result = canvas(
                action="present",
                node=node,
                url=f"http://localhost:18789/__openclaw__/canvas/{filename}"
            )
            
            if result and 'error' not in result:
                return True
            
            # Failed, wait before retry
            wait_time = (2 ** attempt) * 1  # 1s, 2s, 4s
            print(f"Retry {attempt + 1}/{max_retries} in {wait_time}s...")
            time.sleep(wait_time)
            
        except Exception as e:
            print(f"Attempt {attempt + 1} failed: {e}")
            if attempt == max_retries - 1:
                raise
    
    return False
```

---

**Pattern 2: HTML Validation**

```python
def validate_html(html):
    """Basic HTML validation before pushing."""
    errors = []
    
    if not html.strip():
        errors.append("Empty HTML")
    
    if not html.startswith('<!DOCTYPE html>'):
        errors.append("Missing DOCTYPE")
    
    if '<html' not in html or '</html>' not in html:
        errors.append("Missing <html> tags")
    
    if '<body' not in html or '</body>' not in html:
        errors.append("Missing <body> tags")
    
    # Check for unclosed tags (basic)
    open_tags = html.count('<div')
    close_tags = html.count('</div>')
    if open_tags != close_tags:
        errors.append(f"Unclosed <div> tags ({open_tags} open, {close_tags} close)")
    
    return errors

# Usage
html = generate_dashboard(data)
errors = validate_html(html)

if errors:
    print("HTML validation failed:", errors)
    # Fall back to safe default
    html = get_error_display(errors)

push_to_canvas(node, html)
```

---

**Pattern 3: Fallback Display**

```python
def get_error_display(errors):
    """Generate a safe error display."""
    return f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Display Error</title>
        <style>
            body {{
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                background: #0d1117;
                color: #c9d1d9;
                font-family: monospace;
                padding: 2rem;
            }}
            .error-box {{
                background: #161b22;
                border: 2px solid #f85149;
                border-radius: 12px;
                padding: 2rem;
                max-width: 600px;
            }}
            h1 {{ color: #f85149; margin-bottom: 1rem; }}
            ul {{ margin-top: 1rem; }}
            li {{ margin: 0.5rem 0; }}
        </style>
    </head>
    <body>
        <div class="error-box">
            <h1>⚠️ Display Error</h1>
            <p>Failed to render content. Errors:</p>
            <ul>
                {''.join(f'<li>{error}</li>' for error in errors)}
            </ul>
            <p style="margin-top: 1rem; opacity: 0.6;">Retrying in 60 seconds...</p>
        </div>
    </body>
    </html>
    """
```

---

**Pattern 4: Health Monitoring**

```python
class CanvasHealth:
    def __init__(self, node_name):
        self.node_name = node_name
        self.last_success = time.time()
        self.failure_count = 0
        self.status = "healthy"
    
    def record_success(self):
        self.last_success = time.time()
        self.failure_count = 0
        self.status = "healthy"
    
    def record_failure(self):
        self.failure_count += 1
        
        if self.failure_count > 3:
            self.status = "critical"
        elif self.failure_count > 1:
            self.status = "degraded"
    
    def get_status(self):
        time_since_success = time.time() - self.last_success
        
        if time_since_success > 600:  # 10 minutes
            self.status = "stale"
        
        return {
            "node": self.node_name,
            "status": self.status,
            "failures": self.failure_count,
            "last_success": datetime.fromtimestamp(self.last_success).isoformat()
        }

# Usage
health = CanvasHealth("office-tv")

try:
    push_to_canvas("office-tv", html)
    health.record_success()
except Exception as e:
    health.record_failure()
    print("Health status:", health.get_status())
```

---

## TV-Distance Readability

Displays viewed from 6-10 feet require different design considerations.

### Typography Rules

**Minimum sizes for 10-foot viewing:**

| Element | Min Size | Recommended |
|---------|----------|-------------|
| Body text | 1.1rem (17.6px) | 1.3rem (20.8px) |
| Headings | 1.8rem (28.8px) | 2.5rem (40px) |
| Labels | 0.95rem (15.2px) | 1.1rem (17.6px) |
| Captions | 0.85rem (13.6px) | 0.95rem (15.2px) |

**Use `clamp()` for responsive scaling:**

```css
/* Scales from mobile (1rem) to TV (1.3rem) */
body {
  font-size: clamp(1rem, 1.3vw, 1.3rem);
}

/* Heading scales from 1.8rem to 2.5rem */
h1 {
  font-size: clamp(1.8rem, 3vw, 2.5rem);
}
```

---

### Color Contrast

**Minimum contrast ratios:**

- Normal text: **4.5:1** (WCAG AA)
- Large text (≥ 18pt): **3:1**
- UI components: **3:1**

**Design system meets these standards:**

| Combination | Ratio | Pass |
|-------------|-------|------|
| `--text-primary` on `--background` | 12.5:1 | ✓ AAA |
| `--text-secondary` on `--background` | 9.8:1 | ✓ AAA |
| `--text-tertiary` on `--background` | 4.6:1 | ✓ AA |

**Don't use:**
- Gray text below `#7d8590` on dark backgrounds
- Low-contrast borders (use at least `#30363d`)

---

### Spacing & Density

**Thumb rule:** Double your desktop spacing for TV.

```css
/* Desktop */
.card {
  padding: 1rem;
  gap: 0.5rem;
}

/* TV-optimized */
.card {
  padding: clamp(1.2rem, 2vw, 2rem);
  gap: clamp(0.75rem, 1.2vw, 1rem);
}
```

**Grid gaps:** Minimum 1.5rem (24px), recommended 2rem (32px)

---

### Motion & Animation

**Reduced motion for ambient displays:**

- Avoid rapid animations (< 200ms)
- Use long, slow fades (500-1000ms)
- Never auto-scroll faster than 30px/second
- Respect `prefers-reduced-motion`

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

### Information Density

**Maximum content per screen:**

| Display Size | Max Cards | Max Table Rows | Max Timeline Items |
|--------------|-----------|----------------|-------------------|
| 1920×1080 (1080p) | 6-8 | 8-10 | 6-8 |
| 3840×2160 (4K) | 8-12 | 12-15 | 10-12 |

**Prioritize ruthlessly:**
- One primary metric per card
- Top 5-7 items in lists
- Omit secondary details

---

### Testing Checklist

Before deploying to TV:

- [ ] Readable from 10 feet away
- [ ] All text meets 4.5:1 contrast minimum
- [ ] No text smaller than 0.95rem (15.2px)
- [ ] Spacing comfortable (no cramped layouts)
- [ ] Animations slow and smooth
- [ ] Maximum 8 distinct elements per screen
- [ ] Color not the only indicator (use icons/text too)
- [ ] Tested on actual display (not just desktop preview)

---

## Complete Examples

### Example 1: System Metrics Dashboard

**Use case:** Display CPU, memory, disk, network metrics with historical sparklines.

**Data structure:**

```json
{
  "cpu": { "current": 42, "history": [38, 40, 39, 41, 42] },
  "memory": { "current": 67, "total": 16, "used": 10.7 },
  "disk": { "current": 81, "total": 500, "used": 405 },
  "network": { "upload": 2.4, "download": 12.8 }
}
```

**Generation logic:**

```python
def generate_system_dashboard(metrics):
    sparkline_cpu = generate_sparkline_svg(metrics['cpu']['history'])
    
    html = f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>System Metrics</title>
        <style>
            {get_design_system()}
            .grid {{ display: grid; grid-template-columns: repeat(2, 1fr); gap: 2rem; }}
            .metric-card {{
                background: var(--surface);
                border: 1px solid var(--border);
                border-radius: 12px;
                padding: 2rem;
            }}
            .metric-header {{
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 1rem;
            }}
            .metric-label {{
                font-size: 1rem;
                text-transform: uppercase;
                letter-spacing: 0.08em;
                opacity: 0.6;
            }}
            .metric-value {{
                font-size: 3.5rem;
                font-weight: 700;
                line-height: 1;
            }}
            .metric-detail {{
                margin-top: 0.5rem;
                opacity: 0.6;
            }}
        </style>
    </head>
    <body>
        <header>
            <h1>System Metrics</h1>
            <div class="meta">{datetime.now().strftime('%I:%M:%S %p')}</div>
        </header>
        
        <div class="grid">
            <div class="metric-card">
                <div class="metric-header">
                    <div class="metric-label">CPU Usage</div>
                    {sparkline_cpu}
                </div>
                <div class="metric-value">{metrics['cpu']['current']}%</div>
            </div>
            
            <div class="metric-card">
                <div class="metric-header">
                    <div class="metric-label">Memory</div>
                </div>
                <div class="metric-value">{metrics['memory']['current']}%</div>
                <div class="metric-detail">{metrics['memory']['used']:.1f} / {metrics['memory']['total']} GB</div>
            </div>
            
            <div class="metric-card">
                <div class="metric-header">
                    <div class="metric-label">Disk</div>
                </div>
                <div class="metric-value">{metrics['disk']['current']}%</div>
                <div class="metric-detail">{metrics['disk']['used']} / {metrics['disk']['total']} GB</div>
            </div>
            
            <div class="metric-card">
                <div class="metric-header">
                    <div class="metric-label">Network</div>
                </div>
                <div class="metric-value" style="font-size: 2rem;">
                    ↓ {metrics['network']['download']} Mbps
                </div>
                <div class="metric-detail">
                    ↑ {metrics['network']['upload']} Mbps
                </div>
            </div>
        </div>
        
        <script>
            // Auto-refresh every 5 seconds
            setTimeout(() => location.reload(), 5000);
        </script>
    </body>
    </html>
    """
    
    return html
```

**See `examples/data-wall.html` for complete implementation.**

---

### Example 2: Live Event Feed

**Use case:** Real-time feed of Hacker News stories, GitHub events, or system logs.

**Update pattern:** A2UI prepend for new events.

```python
# Initial render
def generate_event_feed():
    html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Live Feed</title>
        <style>/* design system + timeline styles */</style>
    </head>
    <body>
        <header><h1>Live Feed</h1></header>
        <div id="events" class="timeline"></div>
        <script src="/__openclaw__/a2ui-client.js"></script>
    </body>
    </html>
    """
    push_to_canvas("office-tv", html)

# Push new events
def push_event(event):
    send_a2ui_message({
        "type": "surfaceUpdate",
        "surfaceId": "event-feed",
        "targetNode": "office-tv",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "payload": {
            "updateType": "prepend",
            "targetSelector": "#events",
            "content": f"""
            <div class="timeline-item">
                <div class="timeline-marker timeline-marker-info"></div>
                <div class="timeline-content">
                    <div class="timeline-time">{event['time']}</div>
                    <div class="timeline-title">{event['title']}</div>
                </div>
            </div>
            """
        }
    })
```

**See `examples/live-feed.html` for complete implementation.**

---

### Example 3: Project Tracker

**Use case:** Kanban-style project board with progress indicators.

**Layout:** Cards with progress bars, status badges, phase indicators.

```python
def generate_project_tracker(projects):
    cards_html = ""
    
    for project in projects:
        cards_html += f"""
        <div class="project-card">
            <h3>{project['name']}</h3>
            <div class="project-meta">
                <span class="badge badge-{project['status'].lower()}">{project['status']}</span>
                <span>Due {project['due_date']}</span>
            </div>
            <div class="progress-bar-container">
                <div class="progress-bar-header">
                    <span>Progress</span>
                    <span>{project['progress']}%</span>
                </div>
                <div class="progress-bar-track">
                    <div class="progress-bar-fill" style="width: {project['progress']}%"></div>
                </div>
            </div>
            <div class="task-summary">
                {project['completed_tasks']} / {project['total_tasks']} tasks
            </div>
        </div>
        """
    
    return f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Project Tracker</title>
        <style>/* design system + project card styles */</style>
    </head>
    <body>
        <header><h1>Active Projects</h1></header>
        <div class="grid grid-3">{cards_html}</div>
    </body>
    </html>
    """
```

**See `examples/project-tracker.html` for complete implementation.**

---

## Quick Reference

### When to Use Generative UI

✅ **Good for:**
- Dynamic data (APIs, databases, real-time feeds)
- Multi-source dashboards (combine HN + GitHub + weather)
- Personalized displays (different layout per user/time/context)
- Adaptive layouts (grid changes based on data volume)
- Scheduled content rotation (show different views throughout day)

❌ **Not needed for:**
- Static content that never changes
- Single-template scenarios (use canvas-dashboard skill)
- One-off displays

---

### Workflow Cheat Sheet

```python
# 1. Get data
data = fetch_data_from_api()

# 2. Generate HTML
html = compose_ui(data)

# 3. Push to display
push_to_canvas(node="office-tv", html=html)

# 4. Update surgically
update_metric(node="office-tv", selector="#cpu", value="42%")

# 5. Or use A2UI for real-time
send_a2ui_update(node="office-tv", selector="#feed", content="<div>...</div>")
```

---

### Component Selection Guide

| Data Type | Component | Example |
|-----------|-----------|---------|
| Single number | Stat card | User count, revenue, uptime % |
| List of items with status | Status rows | Services, connections, builds |
| Percentage | Progress ring or bar | Task completion, quota |
| Tabular data | Data table | Projects, transactions, logs |
| Time-series events | Timeline | Deployments, commits, alerts |
| Temporary alerts | Toast notifications | Errors, successes, warnings |
| Trend | Sparkline | Historical metrics |

---

## Next Steps

1. **Read the examples:** `examples/live-feed.html`, `project-tracker.html`, `data-wall.html`
2. **Set up a test display:** Follow TV/Ambient Display Infrastructure section
3. **Build your first generative dashboard:** Use the Data-Driven Generation Workflow
4. **Add real-time updates:** Implement A2UI for live data
5. **Deploy to production:** Use the maintain_display() pattern for reliability

---

## Related Skills

- **canvas-dashboard** — Static dashboard templates
- **design-tokens** — Color systems and design variables
- **motion-design-patterns** — Animation guidelines

---

*This skill is maintained as part of the OpenClaw skills repository. Contributions welcome.*
