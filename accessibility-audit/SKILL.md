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

Inject axe-core, **waiting on the load event** rather than a fixed delay:

```javascript
await new Promise((resolve, reject) => {
  const script = document.createElement('script');
  script.src = 'https://cdnjs.cloudflare.com/ajax/libs/axe-core/4.9.1/axe.min.js';
  script.onload = resolve;
  script.onerror = () => reject(new Error('axe-core failed to load'));
  document.head.appendChild(script);
});
```

A `setTimeout` guess fails two ways: a slow CDN response means `axe` is still undefined when you call it, and a page with a restrictive `script-src` CSP blocks the injection entirely while the timer still elapses. Both produce a silent empty scan that reads as a clean page.

**If injection is blocked by CSP**, don't report a pass. Either inject axe-core's source directly through the automation tool (Playwright's `addInitScript`, or evaluating the library source as a string), or report the automated half as unavailable and run the manual protocol alone.

Then run it, **scoped to the standard you're reporting against**:

```javascript
const r = await axe.run({ runOnly: { type: 'tag', values: ['wcag2a','wcag2aa','wcag21a','wcag21aa'] } });

const summarize = items => items.map(v => ({
  id: v.id,
  impact: v.impact,                 // critical | serious | moderate | minor
  description: v.description,
  helpUrl: v.helpUrl,
  nodes: v.nodes.length,
  targets: v.nodes.slice(0, 3).map(n => n.target.join(' '))
}));

JSON.stringify({
  violations: r.violations.length,
  passes: r.passes.length,
  incomplete: r.incomplete.length,
  details: summarize(r.violations),
  needsReview: summarize(r.incomplete)
});
```

**Why `runOnly`:** bare `axe.run()` executes every enabled rule, including `best-practice` and newer-standard rules that are *not* WCAG 2.1 AA requirements. Reporting those under a heading that says "Standard: WCAG 2.1 AA" tells someone they fail a standard they don't fail. Scope to the tags, or label each finding with its ruleset.

**Why `needsReview` is serialized in full:** `incomplete` is checks axe could not decide, and the report below requires listing each one with what to check. A bare count can't populate that section — in browser automation this JSON is usually the only thing that survives the evaluate call. Never fold these into the pass count.

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

// Present but uninformative. Note: alt="" is EXCLUDED — it is the correct
// markup for decorative images, and flagging it produces false positives
// on exactly the pages that got it right.
[...document.querySelectorAll('img[alt]')].filter(i => {
  const alt = i.alt.trim();
  if (alt === '') return false;                       // decorative, correct
  return ['image','photo','picture','icon','logo','graphic'].includes(alt.toLowerCase())
    || /\.(jpg|jpeg|png|gif|webp|svg)$/i.test(alt);
}).map(i => ({ src: i.src.slice(-40), alt: i.alt }));
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

**These are best practices, not WCAG 2.1 AA conformance criteria.** WCAG requires that headings and labels be descriptive (2.4.6, AA) and that structure be programmatically determinable (1.3.1, A) — it does not mandate exactly one `<h1>`, strictly sequential ranks, or any particular landmark. Report findings here as structural recommendations, not as failures of the standard, or the audit claims violations that don't exist.

- [ ] One `<h1>` in most cases — multiple can be legitimate on pages with genuinely parallel top-level sections
- [ ] Ranks generally sequential — a deliberate skip with sound structure is not automatically a defect
- [ ] Headings describe content, not styling *(this one does map to WCAG 2.4.6)*
- [ ] Landmarks used where the regions exist: `<nav>`, `<main>`, `<aside>`, `<footer>`

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

Severity measures **user impact**. It is not the same axis as WCAG conformance level, and collapsing the two misreports both — a weak text alternative is low-impact but can fail Level A, while many AAA items block nobody.

| Level | Impact | Examples |
|-------|--------|----------|
| **Critical** | Blocks access entirely | Missing alt on content images, keyboard trap, modal with no focus management |
| **Serious** | Major barrier | Low-contrast text, unlabeled form fields, no skip link |
| **Moderate** | Degraded experience | Non-descriptive link text ("click here"), confusing heading structure |
| **Minor** | Inconvenience | Alt text that is accurate but unhelpfully terse |

Cite the specific success criterion per finding (e.g. *1.1.1 Non-text Content, Level A*) rather than inferring a level from severity. axe's own `impact` field uses these same four words and maps directly.

Two things that are **not** failures: decorative images with `alt=""`, and contrast on purely decorative elements — decorative content is exempt from contrast requirements, not an AAA-level failure.

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
