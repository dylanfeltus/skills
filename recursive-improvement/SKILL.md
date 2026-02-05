# Recursive Self-Improvement Loop

A pattern for generating higher-quality output by iterating against explicit scoring criteria.

## The Pattern

```
generate → evaluate → diagnose → improve → repeat (until passing)
```

**Never ship first-draft output for important content.** Run the loop.

---

## How It Works

### 1. Generate
Create the initial output as you normally would.

### 2. Evaluate
Score the output against each criterion (1-10). Be brutally honest.

### 3. Diagnose
For any criterion scoring below threshold:
- What specifically is weak?
- Why does it fail?
- What would "passing" look like?

### 4. Improve
Rewrite addressing each diagnosed weakness. Don't patch — rebuild the weak sections.

### 5. Repeat
Re-evaluate. Keep looping until all criteria pass threshold (usually 8/10 minimum).

---

## Adversarial Pressure (Optional but Powerful)

After passing criteria, attack the output from a hostile perspective:
- **Skeptical customer:** "Why should I believe this? What's the catch?"
- **Distracted scroller:** "Would I stop for this? In 2 seconds?"
- **Competitor:** "How would a rival tear this apart?"

If it survives, ship it. If not, iterate.

---

## Agent-Specific Criteria

### Buzz (Content/Social)

**Minimum threshold: 8/10 for each**

| Criterion | What to evaluate |
|-----------|-----------------|
| **Hook strength** | First line grabs attention? Pattern interrupt? |
| **Curiosity gap** | Creates urge to keep reading? |
| **Clarity** | One clear idea? No confusion? |
| **Voice match** | Sounds like the target voice profile? |
| **Engagement bait** | People will reply/share/save? |
| **Thumb-stop power** | Scroller would pause? |
| **Value density** | Every line earns its place? |
| **CTA clarity** | Clear what reader should do next? |

**Adversarial test:** Show to a distracted, skeptical Twitter user at 11pm. Would they engage?

---

### Kai (Web Copy)

**Minimum threshold: 8/10 for each**

| Criterion | What to evaluate |
|-----------|-----------------|
| **Headline clarity** | Instantly clear what this business does? |
| **Value prop strength** | Why choose them over competitors? |
| **Benefit focus** | Features translated to customer benefits? |
| **CTA effectiveness** | Clear, compelling action? Low friction? |
| **Trust signals** | Credibility established? Social proof? |
| **Readability** | Scannable? Short paragraphs? Clear hierarchy? |
| **Objection handling** | Common concerns addressed? |
| **Local relevance** | Location/community connection clear? |

**Adversarial test:** Show to a local business owner searching on their phone. Would they call/click within 30 seconds?

---

## When to Use

**Always use for:**
- Headlines and hooks
- CTAs and value props
- Key landing page sections
- Social posts (especially threads)
- Any "hero" content

**Can skip for:**
- Internal notes
- First-pass brainstorming
- Technical documentation
- Boilerplate content

---

## Quick Loop Template

```markdown
## Output v1
[Initial generation]

## Evaluation v1
- Hook strength: 6/10 — Opens weak, no pattern interrupt
- Clarity: 8/10 — Clear enough
- Voice match: 7/10 — Too formal
[... all criteria]

## Diagnosis
1. Hook needs a surprising stat or contrarian take
2. Voice should be more casual, shorter sentences
3. [...]

## Output v2
[Revised version addressing weaknesses]

## Evaluation v2
[Re-score — continue until all pass]
```

---

## Integration

- **Buzz:** Run loop on all drafts before marking "ready for review"
- **Kai:** Run loop on homepage hero, about section, and CTAs before build is "complete"

The loop adds ~2-3 iterations. Worth it for quality.
