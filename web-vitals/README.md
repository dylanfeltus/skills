# web-vitals

Capture Core Web Vitals and load performance for a page, diagnose what's actually costing time, and report fixes ranked by measured impact.

## Installation

Copy the `web-vitals` folder into your agent's skills directory.

## What's Inside

- **PerformanceObserver recipes** for LCP, CLS, and an INP proxy — plus LCP *element* identification, which is usually where the fix is
- **Navigation and resource timing** extraction: TTFB, FCP, page weight, render-blocking counts, third-party load, and the ten heaviest resources
- **Current thresholds** for LCP / INP / CLS and supporting metrics
- **A symptom → cause → fix table** that maps a bad number to its usual origin
- **Report format** requiring resource-level specificity

## Design Notes

**It's honest about lab vs field.** Everything here is a single load on one machine. Google assesses Core Web Vitals on field data at the 75th percentile over 28 days. The skill uses lab numbers for what they're good at — finding bottlenecks — and explicitly refuses to claim a page "passes Core Web Vitals," since only CrUX, Search Console, or RUM can establish that.

**INP is caveated, not faked.** INP measures real interaction latency. A scripted load with no clicking under-reports it or returns nothing. The skill labels it a lab proxy every time rather than presenting a reassuring number.

**Diagnosis over enumeration.** A high LCP with a low TTFB is a different problem from a high LCP with a high TTFB. The table routes to the actual cause instead of emitting a generic optimization checklist.

## Usage Examples

### Full audit
> "Why is my landing page slow?"

### Metric check
> "What are the Core Web Vitals for example.com?"

### Pre-launch
> "Check performance before we ship this"

## Requirements

A browser automation tool (Playwright, Puppeteer, or an agent browser tool) able to navigate and evaluate JavaScript. No install step or API key.

## License

MIT
