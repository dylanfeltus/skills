# canvas-dashboard

An OpenClaw skill that teaches AI agents to build and push live HTML dashboards to any canvas-connected display — TVs, tablets, monitors, Mac minis.

## What's Included

- **SKILL.md** — Complete agent skill with three embedded dashboard templates (status board, metrics dashboard, ambient display)
- **examples/ambient-clock.html** — Beautiful always-on clock with rotating quotes
- **examples/status-board.html** — Live system status board with service health, agent activity, and event feed

## Installation

Copy the `canvas-dashboard/` directory into your OpenClaw skills folder:

```bash
cp -r canvas-dashboard/ ~/.openclaw/skills/canvas-dashboard/
```

Or reference `SKILL.md` directly from your agent's skill configuration.

## Usage

Once installed, agents can:

1. Write an HTML file to the canvas directory
2. Push it to any display with `canvas(action="present", node="living-room")`
3. Update content live with `canvas(action="eval", javaScript="...")`
4. Capture screenshots with `canvas(action="snapshot")`

See `SKILL.md` for full instructions, templates, and best practices.

## Screenshots

<!-- TODO: Add screenshots of dashboards on actual displays -->

## Requirements

- OpenClaw Gateway with canvas support
- At least one canvas-connected display node
- No external dependencies — all templates are pure HTML/CSS/JS

## License

MIT
