# accessibility-audit

Audit a page against WCAG 2.1 AA using axe-core for the automated pass, plus a manual protocol for everything automation can't see.

## Installation

Copy the `accessibility-audit` folder into your agent's skills directory.

## What's Inside

- **axe-core injection recipe** — CDN load, run, and result extraction, including the `incomplete` results most reports quietly drop
- **Six manual check areas** — contrast, images/media, keyboard navigation, headings/landmarks, forms, ARIA — each with a runnable JS snippet
- **Severity mapping** — Critical/Serious/Moderate/Minor aligned to WCAG levels and to axe's own `impact` field
- **Report format** with selector-level specificity requirements

## Design Notes

**Automation is half the job.** axe-core catches roughly 30–40% of real issues. It sees a missing `alt`; it cannot see that the alt says "image1.jpg". It sees contrast ratios; it cannot see that tab order jumps around the page. The manual protocol is the other half, and skipping it yields a clean report on an unusable page.

**No compliance scores.** The skill explicitly refuses to output "94% WCAG compliant" — automated tooling can't measure conformance, and a score like that is how inaccessible sites ship with a green badge.

**`incomplete` is not `pass`.** axe flags checks it couldn't decide. Those are reported as needing human review, never folded into the pass count.

## Usage Examples

### Full audit
> "Run an accessibility audit on example.com"

### Focused check
> "Is this form accessible?"

### Pre-ship gate
> "Check this page for WCAG AA issues before we deploy"

## Requirements

A browser automation tool (Playwright, Puppeteer, or an agent browser tool) able to navigate and evaluate JavaScript. axe-core loads from CDN at audit time — no install step.

## License

MIT
