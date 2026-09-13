---
name: accessibility-audit
description: Audit a web page for WCAG 2.1 AA accessibility issues using axe-core plus systematic manual checks of contrast, keyboard navigation, headings, forms, and ARIA. Use when the user asks to check accessibility, run an a11y audit, verify WCAG compliance, or asks whether a page is usable with a screen reader or keyboard.
---

# Accessibility Audit

Run a thorough accessibility check on a page: automated axe-core rules first, then the manual checks automation can't do.

**Automated tools catch roughly 30–40% of accessibility issues.** They find missing alt attributes and contrast failures. They cannot tell you whether the alt text is *meaningful*, whether tab order matches visual order, or whether a custom widget is operable. That's why this skill is half automated scan and half manual protocol — skipping the second half produces a clean report on an unusable page.

## When to Use

- User asks to check or audit accessibility, a11y, or WCAG compliance
- User asks "can this be used with a keyboard / screen reader?"
- Pre-ship QA on any user-facing page
- A compliance requirement (WCAG 2.1 AA is the common bar)

## Requirements

A browser automation tool — Playwright, Puppeteer, or an agent browser tool — that can navigate and evaluate JavaScript on the page.

---

## 1. Automated Scan

Inject axe-core and run it:

```javascript
// Inject from CDN
const script = document.createElement('script');
script.src = 'https://cdnjs.cloudflare.com/ajax/libs/axe-core/4.9.1/axe.min.js';
document.head.appendChild(script);
```

Wait for load (~2s), then run and extract:

```javascript
const r = await axe.run();
JSON.stringify({
  violations: r.violations.length,
  passes: r.passes.length,
  incomplete: r.incomplete.length,
  details: r.violations.map(v => ({
    id: v.id,
    impact: v.impact,                 // critical | serious | moderate | minor
    description: v.description,
    helpUrl: v.helpUrl,
    nodes: v.nodes.length,
    targets: v.nodes.slice(0, 3).map(n => n.target.join(' '))
  }))
});
```

`incomplete` matters as much as `violations` — those are checks axe couldn't decide, and they need a human eye. Don't report them as passes.

---

## 2. Manual Checks

### Color & Contrast

- [ ] Text meets WCAG AA (4.5:1 normal, 3:1 for large text)
- [ ] UI components and borders reach 3:1 against their background
- [ ] No information conveyed by color alone — pair with icon, pattern, or text
- [ ] Focus indicators have sufficient contrast against both the element and the page

```javascript
const el = document.querySelector('[selector]');
const s = getComputedStyle(el);
({ color: s.color, background: s.backgroundColor, size: s.fontSize, weight: s.fontWeight });
```

### Images & Media

- [ ] Content images have meaningful `alt` — not "image", "photo", or a filename
- [ ] Decorative images use `alt=""` or `role="presentation"`
- [ ] SVG icons carry `aria-label` or `aria-hidden="true"`
- [ ] Video has captions; audio has a transcript
- [ ] Nothing auto-plays with sound

```javascript
// Missing alt entirely
document.querySelectorAll('img:not([alt])').length;

// Present but useless
[...document.querySelectorAll('img[alt]')].filter(i =>
  ['image','photo','picture','icon','logo',''].includes(i.alt.trim().toLowerCase())
  || /\.(jpg|jpeg|png|gif|webp|svg)$/i.test(i.alt.trim())
).map(i => ({ src: i.src.slice(-40), alt: i.alt }));
```

### Keyboard Navigation

- [ ] Every interactive element is reachable by Tab
- [ ] Tab order follows visual order — no jumping
- [ ] Focus is visible at every stop
- [ ] No keyboard traps — you can Tab out of everything you can Tab into
- [ ] Escape closes modals and dropdowns
- [ ] Enter/Space activate buttons and links
- [ ] A skip-to-content link exists on pages with large navigation

Tab through the page and record the focus order. Compare it against the visual layout:

```javascript
[...document.querySelectorAll(
  'a[href],button,input,select,textarea,[tabindex]:not([tabindex="-1"])'
)].map((el,i) => ({
  i,
  tag: el.tagName,
  tabindex: el.getAttribute('tabindex'),
  label: (el.textContent || el.value || el.getAttribute('aria-label') || '').trim().slice(0,40)
}));
```

Positive `tabindex` values (> 0) are almost always a bug — they override document order and break as soon as the DOM changes.

### Headings & Landmarks

- [ ] Exactly one `<h1>`
- [ ] No skipped levels (h1 → h3)
- [ ] Headings describe structure, not styling
- [ ] Landmarks present: `<nav>`, `<main>`, `<aside>`, `<footer>`

```javascript
// Hierarchy, with skip detection
let prev = 0;
[...document.querySelectorAll('h1,h2,h3,h4,h5,h6')].map(h => {
  const lvl = +h.tagName[1];
  const skipped = prev && lvl > prev + 1;
  prev = lvl;
  return `${skipped ? '⚠️ SKIP ' : ''}${h.tagName}: ${h.textContent.trim().slice(0,50)}`;
});

// Landmarks
[...document.querySelectorAll('nav,main,aside,footer,header,[role]')]
  .map(l => `${l.tagName} role=${l.getAttribute('role') || 'implicit'}`);
```

### Forms

- [ ] Every input has an associated `<label>` (via `for`/`id` or wrapping)
- [ ] Required fields marked by more than color
- [ ] Errors linked to their field via `aria-describedby`
- [ ] Validation messages reach screen readers (`aria-live` or focus management)
- [ ] Placeholder is never the only label — it disappears on input

```javascript
[...document.querySelectorAll('input,select,textarea')].filter(i => {
  if (i.type === 'hidden') return false;
  const byFor = i.id && document.querySelector(`label[for="${CSS.escape(i.id)}"]`);
  return !byFor && !i.closest('label')
    && !i.getAttribute('aria-label') && !i.getAttribute('aria-labelledby');
}).map(i => ({ tag: i.tagName, type: i.type, name: i.name, placeholder: i.placeholder }));
```

### ARIA

- [ ] Roles are accurate — `role="button"` on a `<div>` also needs key handling and `tabindex`
- [ ] `aria-expanded` on anything that toggles
- [ ] `aria-live` on regions that update dynamically
- [ ] `aria-hidden="true"` never wraps a focusable element
- [ ] No redundant ARIA (`role="link"` on an `<a>`)

```javascript
// Focusable content hidden from assistive tech — a real trap
[...document.querySelectorAll('[aria-hidden="true"]')]
  .filter(el => el.querySelector('a[href],button,input,select,textarea,[tabindex]:not([tabindex="-1"])'))
  .map(el => el.tagName + '.' + el.className);
```

The first rule of ARIA is not to use ARIA: a native `<button>` beats `role="button"` every time.

---

## 3. Severity

| Level | Impact | WCAG | Examples |
|-------|--------|------|----------|
| **Critical** | Blocks access entirely | A | Missing alt on content images, keyboard trap, modal with no focus management |
| **Serious** | Major barrier | A/AA | Low-contrast text, unlabeled form fields, no skip link |
| **Moderate** | Degraded experience | AA | Broken heading hierarchy, missing landmarks, "click here" link text |
| **Minor** | Inconvenience | AAA | Weak alt text, low contrast on decorative elements |

Map axe's own `impact` field onto this directly — it uses the same four words.

---

## 4. Report

```markdown
## Accessibility Audit — [URL] — [date]

**Standard:** WCAG 2.1 AA
**Automated:** X violations, Y passes, Z incomplete (need review)
**Manual issues:** X

### Critical
1. **[Issue]** — `[selector]` — [why it blocks] → **Fix:** [specific change]

### Serious
1. **[Issue]** — `[selector]` — [impact] → **Fix:** [change]

### Moderate
1. **[Issue]** — `[selector]` → **Fix:** [change]

### Needs Human Review
- [Anything axe marked incomplete, with what to check]

### Quick Wins (under 30 min)
1. [Fix] — affects N elements

### Passing
- [What's genuinely solid — worth stating]
```

## Reporting Rules

1. **Always give a selector.** "Improve contrast" is not actionable; "`.hero__subtitle` is #999 on #fff (2.8:1), needs #767676 or darker" is.
2. **Never report a percentage score as compliance.** Automated tooling can't measure WCAG conformance, and claiming it can is how inaccessible sites ship with a green badge.
3. **Report `incomplete` separately.** They are unknowns, not passes.
4. **Lead with what blocks users**, not with what's easiest to fix.
