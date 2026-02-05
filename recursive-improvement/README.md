# Recursive Self-Improvement Loop

A pattern for generating higher-quality AI output by iterating against explicit scoring criteria.

## The Pattern

```
generate → evaluate → diagnose → improve → repeat (until passing)
```

Most people prompt once and ship whatever comes back. This skill works differently — it generates, evaluates against a scoring checklist, diagnoses weaknesses, rewrites, and re-evaluates. It keeps looping until the output actually hits the bar.

## Quick Start

1. Copy `SKILL.md` into your AI's context
2. Define your scoring criteria (or use the examples provided)
3. Set minimum thresholds (usually 8/10)
4. Let the AI iterate until all criteria pass

## Example Criteria

**For social content:**
- Hook strength
- Curiosity gap  
- Clarity
- Voice match
- Engagement potential

**For web copy:**
- Headline clarity
- Value prop strength
- CTA effectiveness
- Trust signals
- Readability

## When to Use

✅ Headlines and hooks  
✅ CTAs and value props  
✅ Landing page copy  
✅ Social posts and threads  
✅ Ad copy  

❌ Internal notes  
❌ First-pass brainstorming  
❌ Technical docs  

---

See `SKILL.md` for the full implementation details.
