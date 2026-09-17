---
name: web-vitals
description: Capture Core Web Vitals (LCP, INP, CLS) and load performance for a page, identify what's slowing it down, and report optimization opportunities. Use when the user asks why a site is slow, wants a performance audit, mentions Core Web Vitals or PageSpeed, or asks about load time, page weight, or render-blocking resources.
---

# Web Vitals

Measure a page's real load performance, find what's costing time, and report fixes ranked by impact.

## When to Use

- User asks why a page or site is slow
- User wants a performance audit or PageSpeed-style report
- User mentions Core Web Vitals, LCP, INP, CLS, or TTFB
- Pre-launch performance check
- Investigating an SEO ranking drop with a performance component

## Requirements

A browser automation tool (Playwright, Puppeteer, or an agent browser tool) that can navigate and evaluate JavaScript.

## Lab vs Field — read this first

What this skill measures is **lab data**: one load, on one machine, on one network. Google assesses Core Web Vitals on **field data at the 75th percentile** of real page views over 28 days.

They routinely disagree. A page that measures 1.9s LCP here can still fail in the field because real users are on slower devices and worse networks. So:

- Use these numbers to **find and fix bottlenecks** — that's what they're good for.
- Do **not** report them as "this page passes Core Web Vitals." Only field data (Search Console, CrUX, or RUM) can say that.
- **INP in particular is barely meaningful in the lab.** It measures real interaction latency; a scripted load with no clicking will under-report it or return nothing at all.

---

## 1. Core Web Vitals

Register observers **before** navigation where the tool allows it, so buffered entries are captured:

```javascript
// LCP — Largest Contentful Paint
new PerformanceObserver(list => {
  const entries = list.getEntries();
  window.__lcp = entries[entries.length - 1].startTime;
}).observe({ type: 'largest-contentful-paint', buffered: true });

// CLS — largest session window, NOT a running total.
// A session window ends after a 1s gap between shifts, or at 5s total.
// CLS is the maximum window score, so isolated small shifts across a long
// page do not accumulate into a failing grade the user never experienced.
let cls = 0, cur = 0, first = 0, last = 0;
new PerformanceObserver(list => {
  for (const e of list.getEntries()) {
    if (e.hadRecentInput) continue;
    if (cur && (e.startTime - last > 1000 || e.startTime - first > 5000)) {
      cls = Math.max(cls, cur); cur = 0;
    }
    if (!cur) first = e.startTime;
    last = e.startTime;
    cur += e.value;
  }
  window.__cls = Math.max(cls, cur);
}).observe({ type: 'layout-shift', buffered: true });

// INP proxy — worst observed interaction latency.
// Requires actual interaction to mean anything.
let worst = 0;
new PerformanceObserver(list => {
  for (const e of list.getEntries()) if (e.duration > worst) worst = e.duration;
  window.__inp = worst;
}).observe({ type: 'event', buffered: true, durationThreshold: 16 });
```

Let the page settle (3s+), interact with it if you want a usable INP number, then read `__lcp`, `__cls`, `__inp`.

Also identify *what* the LCP element actually is — it's usually the fix:

```javascript
new PerformanceObserver(list => {
  const e = list.getEntries().at(-1);
  window.__lcpEl = {
    tag: e.element?.tagName,
    src: e.element?.currentSrc || e.element?.src || null,
    cls: e.element?.className,
    size: e.size
  };
}).observe({ type: 'largest-contentful-paint', buffered: true });
```

## 2. Load Timeline

```javascript
const nav = performance.getEntriesByType('navigation')[0];
const paint = performance.getEntriesByType('paint');
({
  ttfb: nav.responseStart - nav.requestStart,
  fcp: paint.find(p => p.name === 'first-contentful-paint')?.startTime,
  domContentLoaded: nav.domContentLoadedEventEnd - nav.startTime,
  fullLoad: nav.loadEventEnd - nav.startTime,
  transferSize: nav.transferSize,
  decodedSize: nav.decodedBodySize,
  dns: nav.domainLookupEnd - nav.domainLookupStart,
  tcp: nav.connectEnd - nav.connectStart,
  tls: nav.secureConnectionStart > 0 ? nav.connectEnd - nav.secureConnectionStart : 0,
  redirects: nav.redirectCount
});
```

## 3. Resources & Render Blocking

**Before trusting any byte count here:** `transferSize` is reported as `0` for cached resources *and* for cross-origin resources that don't send `Timing-Allow-Origin`. That's most CDN and third-party assets. Taken at face value, a 2MB third-party script ranks below a 4KB local one. Fall back to `decodedBodySize`, and track how much of the total is unmeasurable:

```javascript
const res = performance.getEntriesByType('resource');
const by = t => res.filter(r => r.initiatorType === t);

// transferSize || decodedBodySize; 0 from both means genuinely unknown
const size = r => r.transferSize || r.decodedBodySize || 0;
const kb = rs => Math.round(rs.reduce((s, r) => s + size(r), 0) / 1024);
const isFont = r => /\.(woff2?|ttf|otf|eot)(\?|$)/i.test(r.name) || r.initiatorType === 'font';
const opaque = res.filter(r => !r.transferSize && !r.decodedBodySize);

({
  total: res.length,
  weightKB: kb(res),
  unmeasured: opaque.length,   // cached or cross-origin without Timing-Allow-Origin
  unmeasuredHosts: [...new Set(opaque.map(r => { try { return new URL(r.name).host } catch { return '?' } }))].slice(0,5),
  scripts: { n: by('script').length, kb: kb(by('script')) },
  css:     { n: by('link').length,   kb: kb(by('link')) },
  images:  { n: by('img').length,    kb: kb(by('img')) },
  fonts:   { n: res.filter(isFont).length, kb: kb(res.filter(isFont)) },

  // Render blocking
  syncScripts: document.querySelectorAll(
    'head script[src]:not([async]):not([defer]):not([type="module"])'
  ).length,
  headStylesheets: document.querySelectorAll('head link[rel="stylesheet"]').length,

  // Third party
  thirdParty: res.filter(r => !r.name.includes(location.hostname)).length,
  thirdPartyKB: kb(res.filter(r => !r.name.includes(location.hostname))),

  // Hints
  preconnect: document.querySelectorAll('link[rel="preconnect"]').length,
  preload:    document.querySelectorAll('link[rel="preload"]').length,

  // Basics
  viewport: !!document.querySelector('meta[name="viewport"]'),

  // Heaviest individual resources — usually where the win is
  top: res.map(r => ({
        url: r.name.split('/').pop().slice(0,50),
        kb: Math.round(size(r)/1024),
        measured: !!(r.transferSize || r.decodedBodySize)
      }))
      .sort((a,b) => b.kb - a.kb).slice(0, 10)
});
```

If `unmeasured` is more than a handful, say so in the report rather than presenting the weight total as complete. For real numbers on those, read response sizes from the automation tool's network layer (Playwright's `response.body()`, or a CDP `Network.responseReceived` listener) instead of Resource Timing.

Also check for the classic CLS cause — images without reserved space:

```javascript
// EITHER dimension missing leaves the box unreserved: one alone doesn't
// establish the aspect ratio before the image loads.
[...document.querySelectorAll('img')].filter(i => {
  const hasBoth = i.getAttribute('width') && i.getAttribute('height');
  const ratio = i.style.aspectRatio || getComputedStyle(i).aspectRatio;
  const hasRatio = ratio && ratio !== 'auto';
  return !hasBoth && !hasRatio;
}).map(i => i.currentSrc || i.src);
```

---

## 4. Thresholds

Core Web Vitals, per [web.dev](https://web.dev/articles/vitals):

| Metric | Good | Needs improvement | Poor |
|--------|------|-------------------|------|
| **LCP** | ≤ 2.5s | 2.5 – 4s | > 4s |
| **INP** | ≤ 200ms | 200 – 500ms | > 500ms |
| **CLS** | ≤ 0.1 | 0.1 – 0.25 | > 0.25 |

Supporting metrics:

| Metric | Good | Needs improvement | Poor |
|--------|------|-------------------|------|
| FCP | < 1.8s | 1.8 – 3s | > 3s |
| TTFB | < 800ms | 800ms – 1.8s | > 1.8s |
| Total requests | < 50 | 50 – 100 | > 100 |
| Page weight | < 1MB | 1 – 3MB | > 3MB |

---

## 5. Diagnosis

Map the symptom to its usual cause rather than listing generic advice:

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| High TTFB | Slow server, no caching, redirect chain | Server cache, CDN, remove redirects |
| High LCP, low TTFB | LCP image loads late or is oversized | `fetchpriority="high"`, preload it, serve modern formats, stop lazy-loading it |
| LCP element is text | Web font blocking render | `font-display: swap`, preload the font, subset it |
| High CLS | Images/ads/embeds without reserved space | Set `width`/`height` or `aspect-ratio`; reserve ad slots |
| CLS late in load | Font swap reflow, injected banners | Match fallback metrics via `size-adjust`; reserve banner space |
| High INP | Long tasks blocking the main thread | Break up long tasks, defer non-critical JS, `yield()` in handlers |
| Slow FCP | Render-blocking CSS/JS in `<head>` | Inline critical CSS, `defer` scripts |
| Heavy page | Unoptimized images, large bundles | WebP/AVIF, responsive `srcset`, code splitting |

---

## 6. Report

```markdown
## Performance Snapshot — [URL] — [date]

*Lab measurement, single load. Not a substitute for field data.*

### Core Web Vitals
| Metric | Value | Rating |
|--------|-------|--------|
| LCP | X.Xs | 🟢/🟡/🔴 |
| INP | Xms | 🟢/🟡/🔴 (lab proxy) |
| CLS | 0.XX | 🟢/🟡/🔴 |

**LCP element:** `[tag/selector]` — [what it is]

### Load Timeline
TTFB Xms → FCP Xms → DOM Ready Xms → Load Xms

### Weight
| | Count | Size |
|---|---|---|
| Total | X | X KB |
| Scripts | X | X KB |
| Images | X | X KB |
| Third-party | X | X KB |

**Heaviest:** [top 3 by size]

### Top Issues
1. **[Issue]** — costing ~[X]ms/[X]KB → **Fix:** [specific change]

### Quick Wins
1. [Change] — est. [impact]
```

## Reporting Rules

1. **Name the specific resource.** "Optimize images" is noise; "`hero.png` is 2.3MB and is the LCP element — serve WebP at 1600px wide" is a task.
2. **Never claim the page passes Core Web Vitals.** Lab data can't establish that. Point at Search Console or CrUX for the real verdict.
3. **Caveat INP** every time it comes from a scripted load.
4. **Rank by measured cost**, not by how easy the fix is.
