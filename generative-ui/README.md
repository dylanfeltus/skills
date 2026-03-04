# Generative UI

**Dynamically generate and push live HTML/CSS/JS interfaces to OpenClaw canvas display surfaces.**

Turn arbitrary data (JSON, APIs, events) into polished, real-time dashboards and ambient displays.

---

## What Is This?

Generative UI teaches AI agents to **compose** user interfaces programmatically from dynamic data.

**Two approaches in one skill:**

1. **Quick Start Templates** — Three production-ready HTML files you can deploy in < 5 minutes (status board, metrics dashboard, ambient display)
2. **Programmatic Generation** — Build adaptive UIs from arbitrary data using components and patterns

**When to use each:**

| Static Templates | Programmatic Generation |
|------------------|-------------------------|
| Need something running in < 5 minutes | Complex, multi-source dashboards |
| Use case matches a template | Data structure is dynamic |
| Starting point to customize | Layout adapts to content |
| Simple, fixed layout | Real-time surgical updates |

---

## What's Inside

### SKILL.md (Main Documentation)

Comprehensive guide covering:

- **Component Library** — 8 production-ready UI components (stat cards, timelines, progress rings, tables, etc.) with copy-paste HTML/CSS
- **Design System** — Dark theme, CSS variables, typography scale, responsive grids
- **A2UI Protocol** — OpenClaw's v0.8 protocol for real-time UI updates via JSONL
- **Live Update Patterns** — Three patterns: full-page regeneration, surgical eval updates, A2UI surface updates
- **TV/Ambient Display Infrastructure** — How to set up Mac mini/iPad/Raspberry Pi as canvas nodes
- **Data-Driven Generation Workflow** — Step-by-step: data → analysis → component selection → HTML generation → push → verify
- **Error Handling** — Retry patterns, validation, fallback displays, health monitoring
- **TV-Distance Readability** — Typography, contrast, spacing, motion guidelines for 10-foot viewing

### Quick Start Templates

The skill now includes three ready-to-deploy static templates for rapid deployment:

- **Status Board** — Service health, agent activity, metrics, events (auto-refreshes every 10s)
- **Metrics Dashboard** — KPI cards with pure CSS/JS sparklines
- **Ambient Display** — Always-on clock with rotating quotes and slow gradient background

See the [Quick Start Templates](#quick-start-templates) section in SKILL.md for full HTML.

### Dynamic Examples

Three production-ready HTML files showing programmatic generation patterns:

#### `examples/live-feed.html`
Real-time scrolling event feed. Shows HN stories, GitHub activity, or system logs. Dark theme, auto-updates, no CDN dependencies.

**Features:**
- Infinite scroll timeline
- Auto-refresh every 30 seconds
- Smooth fade-in animations
- A2UI-ready for live updates

---

#### `examples/project-tracker.html`
Kanban-style project board with progress bars, task counts, and status indicators.

**Features:**
- Grid of project cards
- Progress visualization (bars + percentages)
- Status badges (active, review, blocked)
- Phase indicators

---

#### `examples/data-wall.html`
Multi-source data dashboard: clock, weather, HN top stories, system metrics.

**Features:**
- 4-panel grid layout
- Live clock with date
- Weather placeholder (API-ready)
- Top 5 HN stories
- System metrics with sparklines

---

## Quick Start

### 1. Read the Skill

Start with [SKILL.md](./SKILL.md) — it's comprehensive but organized into clear sections. Jump to what you need:

- **Building your first dashboard?** → [Data-Driven Generation Workflow](#data-driven-generation-workflow)
- **Need UI components?** → [Component Library](#component-library)
- **Want real-time updates?** → [A2UI Protocol Integration](#a2ui-protocol-integration)
- **Setting up a TV display?** → [TV/Ambient Display Infrastructure](#tvambient-display-infrastructure)

### 2. Try the Examples

Open the examples in a browser to see them in action:

```bash
# Serve locally
cd examples
python3 -m http.server 8000

# Open in browser
open http://localhost:8000/live-feed.html
```

Or push directly to a canvas node:

```python
# Copy to canvas directory
cp examples/live-feed.html ~/.openclaw/canvas/

# Push to display
canvas(action="present", 
       node="office-tv",
       url="http://localhost:18789/__openclaw__/canvas/live-feed.html")
```

### 3. Generate Your First UI

Use the Data-Driven Generation Workflow pattern:

```python
def generate_dashboard(data):
    """Generate dashboard HTML from arbitrary data."""
    
    # 1. Analyze data structure
    metrics = data.get('metrics', {})
    events = data.get('events', [])
    
    # 2. Select components
    # Top: stat cards for metrics
    # Bottom: timeline for events
    
    # 3. Compose HTML
    html = f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Dashboard</title>
        <style>{get_design_system()}</style>
    </head>
    <body>
        <div class="grid">
            {generate_stat_cards(metrics)}
        </div>
        <div class="timeline">
            {generate_timeline(events)}
        </div>
    </body>
    </html>
    """
    
    # 4. Push to canvas
    write("~/.openclaw/canvas/dashboard.html", html)
    canvas(action="present", node="office-tv", 
           url="http://localhost:18789/__openclaw__/canvas/dashboard.html")
    
    return html

# Usage
data = fetch_from_api()
generate_dashboard(data)
```

---

## Use Cases

### Ambient Office Displays

Generate always-on dashboards for TVs/monitors:
- Team project status
- Build/deployment status
- Service health
- Real-time metrics (traffic, sales, signups)

### Data Walls

Combine multiple data sources into one display:
- Weather + calendar + news
- GitHub activity + HN trends
- System metrics + recent deploys
- Custom business metrics

### Real-Time Feeds

Stream live events to displays:
- Customer activity feed
- System logs
- Social media mentions
- Transaction monitoring

### Personal Dashboards

Generate personalized displays:
- Family calendar + todo list
- Stock portfolio + news
- Fitness metrics + weather
- Morning briefing (customized by time of day)

---

## Key Concepts

### Component-Based Generation

Don't write full HTML files. Compose from reusable components:

```python
# ❌ Monolithic HTML generation
html = "<div>...</div><div>...</div>..."  # fragile, hard to maintain

# ✅ Component composition
html = f"""
{header(title, subtitle)}
<div class="grid">
    {stat_card("Users", user_count, trend)}
    {stat_card("Revenue", revenue, trend)}
</div>
{timeline(recent_events)}
"""
```

### Adaptive Layouts

Layout should respond to data, not just screen size:

```python
# Adjust grid columns based on number of items
if len(items) <= 3:
    grid_class = "grid-3"
elif len(items) <= 6:
    grid_class = "grid-2"
else:
    grid_class = "grid"  # auto-fit

html = f'<div class="{grid_class}">{cards}</div>'
```

### Surgical Updates

Update specific elements without full page reload:

```python
# Full-page: slow, loses state
regenerate_entire_dashboard()

# Surgical: fast, preserves state
canvas(action="eval", node="office-tv",
       javaScript="document.querySelector('#cpu').textContent = '42%'")
```

---

## Architecture Patterns

### Pattern 1: Generate Once, Update Forever

```python
# Initial render (full HTML)
generate_dashboard(initial_data)

# Subsequent updates (surgical)
while True:
    new_data = fetch_latest()
    update_metrics_surgically(new_data)
    time.sleep(10)
```

**When:** Stable layout, frequent data updates (e.g., system metrics)

---

### Pattern 2: Regenerate on Data Shape Change

```python
last_structure = None

while True:
    data = fetch_data()
    structure = analyze_structure(data)
    
    if structure != last_structure:
        # Data shape changed, regenerate
        generate_dashboard(data)
        last_structure = structure
    else:
        # Same structure, surgical update
        update_values(data)
    
    time.sleep(60)
```

**When:** Dynamic data sources where fields may appear/disappear

---

### Pattern 3: A2UI Streaming

```python
# Render once with empty containers
generate_shell()

# Stream updates via A2UI
for event in event_stream:
    send_a2ui_message({
        "type": "surfaceUpdate",
        "payload": {
            "updateType": "prepend",
            "targetSelector": "#feed",
            "content": render_event(event)
        }
    })
```

**When:** Real-time feeds, multi-agent updates, event-driven UIs

---

## Design Principles

### 1. Dark Theme by Default

All examples use dark theme optimized for ambient viewing:
- Reduces eye strain
- Better for 24/7 displays
- Saves power on OLED screens

### 2. No External Dependencies

All HTML is self-contained:
- No CDN links (no network failures)
- No external fonts (faster load, works offline)
- Inline CSS/JS (single-file deploy)

### 3. TV-Distance Readable

Typography and spacing optimized for 10-foot viewing:
- Minimum 1.1rem body text
- High contrast (4.5:1 minimum)
- Generous spacing (2rem grid gaps)
- Large touch targets (for tablet displays)

### 4. Viewport Responsive

Use `clamp()` for fluid scaling:

```css
/* Scales from mobile to 4K */
font-size: clamp(1rem, 1.3vw, 1.3rem);
padding: clamp(1rem, 2vw, 2rem);
```

### 5. Graceful Degradation

Handle missing data elegantly:

```python
# ❌ Crashes if data missing
html = f"<div>{data['required_field']}</div>"

# ✅ Handles missing data
value = data.get('required_field', 'N/A')
html = f"<div>{value}</div>"
```

---

## Common Patterns

### Stat Card Grid

```python
metrics = [
    ("Active Users", 1247, "+12%"),
    ("Revenue", "$8,420", "+8%"),
    ("Uptime", "99.9%", "")
]

cards = "".join([
    f"""<div class="stat-card">
        <div class="stat-label">{label}</div>
        <div class="stat-value">{value}</div>
        {f'<div class="stat-trend positive">{trend}</div>' if trend else ''}
    </div>"""
    for label, value, trend in metrics
])

html = f'<div class="grid grid-3">{cards}</div>'
```

### Timeline from Events

```python
timeline_html = "".join([
    f"""<div class="timeline-item">
        <div class="timeline-marker timeline-marker-info"></div>
        <div class="timeline-content">
            <div class="timeline-time">{event['time']}</div>
            <div class="timeline-title">{event['title']}</div>
        </div>
    </div>"""
    for event in events[:10]  # Top 10 only
])

html = f'<div class="timeline">{timeline_html}</div>'
```

### Data Table

```python
rows = "".join([
    f"""<tr>
        <td><strong>{row['name']}</strong></td>
        <td><span class="badge badge-{row['status']}">{row['status']}</span></td>
        <td>{row['value']}</td>
    </tr>"""
    for row in data
])

html = f"""
<table class="data-table">
    <thead>
        <tr><th>Name</th><th>Status</th><th>Value</th></tr>
    </thead>
    <tbody>{rows}</tbody>
</table>
"""
```

---

## Troubleshooting

### Display Not Updating

**Check:**
1. Canvas node is online: `canvas(action="list-nodes")`
2. File was written: `ls ~/.openclaw/canvas/`
3. URL is correct: `http://localhost:18789/__openclaw__/canvas/yourfile.html`
4. Snapshot shows content: `canvas(action="snapshot", node="office-tv")`

**Fix:**
```python
# Force refresh
canvas(action="navigate", node="office-tv", 
       url="http://localhost:18789/__openclaw__/canvas/yourfile.html?t=" + str(time.time()))
```

### Layout Broken on TV

**Check:**
1. View on actual TV, not desktop browser
2. Text readable from 10 feet
3. Using `clamp()` for responsive sizing
4. Contrast meets 4.5:1 minimum

**Fix:**
```css
/* Increase minimum sizes */
body { font-size: clamp(1.1rem, 1.5vw, 1.5rem); }
h1 { font-size: clamp(2rem, 3.5vw, 3rem); }
```

### A2UI Not Working

**Check:**
1. WebSocket connection established (check browser console)
2. Gateway running: `openclaw gateway status`
3. Message format correct (valid JSON)
4. Target selector exists in DOM

**Fix:**
```javascript
// Add connection status indicator
ws.onopen = () => console.log("A2UI connected");
ws.onerror = (e) => console.error("A2UI error:", e);
```

---

## Best Practices

### ✅ Do

- Validate HTML before pushing
- Use the design system variables
- Handle missing data gracefully
- Test on actual display hardware
- Keep components small and focused
- Use semantic HTML
- Add ARIA labels for accessibility
- Monitor display health
- Version your generated files
- Log generation errors

### ❌ Don't

- Hardcode colors/sizes (use CSS variables)
- Use CDN dependencies
- Generate invalid HTML
- Assume data structure
- Ignore error states
- Skip snapshot verification
- Use tiny fonts (< 1rem)
- Animate rapidly (< 200ms)
- Overload displays (> 8 cards)
- Trust external APIs without fallbacks

---

## Performance Tips

1. **Lazy load images**: Use `loading="lazy"` on all images
2. **Minimize reflows**: Update text content, not layout properties
3. **Batch updates**: Group DOM changes together
4. **Debounce rapid updates**: Max 1 update per second per element
5. **Clean old files**: Delete canvas files older than 7 days
6. **Cache generated components**: Reuse HTML snippets when data unchanged

---

## Contributing

Improvements welcome! Particularly:

- New component patterns
- Real-world use case examples
- TV/display setup guides
- Performance optimizations
- Error handling patterns

---

## Related Skills

- **design-tokens** — Color systems and design variable management
- **motion-design-patterns** — Animation timing and easing guidelines

---

## License

Part of the OpenClaw skills repository. MIT License.

---

## Support

Questions? Issues? Open a GitHub issue or check the [main skill documentation](./SKILL.md).

**Key sections to reference:**
- Component Library — Copy-paste UI components
- A2UI Protocol — Real-time update protocol
- Data-Driven Workflow — Step-by-step generation pattern
- Error Handling — Retry logic and validation
- TV-Distance Readability — Typography and spacing guidelines
