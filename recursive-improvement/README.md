# Recursive Self-Improvement Loop

A pattern for generating higher-quality AI output by iterating against explicit scoring criteria.

## The Pattern

```
generate → evaluate → diagnose → improve → repeat (until passing)
```

Most people prompt once and ship whatever comes back. This skill works differently — it generates, evaluates against a scoring checklist, diagnoses weaknesses, rewrites, and re-evaluates. It keeps looping until the output actually hits the bar.

## Quick Start

1. Copy `SKILL.md` into your AI's context (system prompt, project docs, or paste directly)
2. Pick the relevant criteria for your use case (or define your own)
3. Set minimum thresholds (usually 8/10)
4. Let the AI iterate until all criteria pass

## Included Criteria

The skill includes ready-to-use scoring criteria for:

- **Social content** — hooks, engagement, thumb-stop power
- **Landing pages** — headlines, value props, CTAs
- **Email copy** — subject lines, skimmability, single focus
- **Ad copy** — pattern interrupts, emotional triggers, platform fit

Plus a framework for building your own criteria for any repeatable task.

## When to Use

✅ Headlines and hooks  
✅ CTAs and value props  
✅ Landing page copy  
✅ Social posts and threads  
✅ Ad copy  
✅ Important emails

❌ Internal notes  
❌ First-pass brainstorming  
❌ Technical docs  

## The Secret Sauce

The real power is in **adversarial pressure** — after the output passes your criteria, you attack it:

- "Would a skeptical customer believe this?"
- "Would a distracted scroller stop for this?"
- "How would a competitor tear this apart?"

If it survives the attack, ship it. If not, iterate.

---

See `SKILL.md` for the full implementation.
