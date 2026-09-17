# visual-qa

Use vision models to self-review screenshots against design intent. Catch spacing issues, alignment problems, color inconsistencies, responsive bugs, and accessibility gaps before shipping.

## Installation

Copy the `visual-qa` folder into your agent's skills directory.

## What's Inside

- **7 review categories** in priority order: layout, typography, color, hierarchy, components, polish, responsive
- **Structured output formats** for full reviews, quick reviews, and mockup comparisons
- **Vision model prompts** tuned for different review types
- **Breakpoint boundary testing** — capture at width-1 / width / width+1 to catch off-by-one media queries
- **Two report formats** — a quick 🔴/🟡/🟢 review, and a trackable P0–P3 report with a re-check queue
- **Build workflow integration** — when and how to run QA during development

## Usage Examples

### Review a page
> "Review this landing page screenshot"

### Compare to mockup
> "Does my implementation match this Figma design?"

### Check mobile
> "Check if this component looks good on mobile"

## Requirements

Requires a vision-capable model (GPT-4o, Claude, Gemini) and the ability to capture screenshots (browser tool, Peekaboo, or user-provided images).

## License

MIT
