# Skills Library

A collection of reusable AI agent skills for research, intelligence gathering, design, web quality, and everyday workflow. Drop a folder into your agent's skills directory and it just works.

## What are skills?

Skills are structured instructions that give AI agents domain expertise and systematic workflows. Instead of prompting from scratch, you load a skill and get consistent, high-quality output. Works with OpenClaw, Claude Code, Cursor, and other LLM-based tools.

## Available Skills

### Research & Intelligence

| Skill | Description | Auth Required |
|-------|-------------|---------------|
| [hn-search](./hn-search/) | Search & monitor Hacker News via the Algolia API | ❌ Free, no key |
| [producthunt](./producthunt/) | Search Product Hunt launches via GraphQL V2 API | ✅ Free dev token (~2 min setup) |
| [appstore-intel](./appstore-intel/) | App Store ratings, reviews, and metadata (iOS + Android) | ❌ Free, no key |
| [trademark-search](./trademark-search/) | USPTO trademark availability search | ❌ Free, no key |

### Agent Commerce

| Skill | Description | Auth Required |
|-------|-------------|---------------|
| [privacy-cards](./privacy-cards/) | Create virtual cards for agent purchases via Privacy.com API | ✅ Privacy.com API key |

### Design & Web Quality

| Skill | Description | Auth Required |
|-------|-------------|---------------|
| [motion-design-patterns](./motion-design-patterns/) | Framer Motion patterns — springs, staggers, layout animations, micro-interactions | ❌ None |
| [design-tokens](./design-tokens/) | Type scales, color palettes, spacing grids, WCAG contrast, dark mode derivation | ❌ None |
| [creative-direction](./creative-direction/) | Image prompt templates, model selection, anti-generic patterns | ❌ None |
| [visual-qa](./visual-qa/) | Screenshot review against design intent using vision models | ❌ None |
| [accessibility-audit](./accessibility-audit/) | WCAG 2.1 AA audit — axe-core scan plus manual keyboard, ARIA, and contrast checks | ❌ None |
| [web-vitals](./web-vitals/) | Core Web Vitals, load performance, and render-blocking diagnosis | ❌ None |

### Productivity

| Skill | Description | Auth Required |
|-------|-------------|---------------|
| [inbox-triage](./inbox-triage/) | Triage email by urgency, draft replies, generate a digest — never sends | ✅ Gmail connector or IMAP |

### Engineering

| Skill | Description | Auth Required |
|-------|-------------|---------------|
| [repo-hygiene](./repo-hygiene/) | Stale branches, PR triage, issue flagging, README drift detection | ✅ `gh` CLI or GitHub token |

### Content & Quality

| Skill | Description | Auth Required |
|-------|-------------|---------------|
| [recursive-improvement](./recursive-improvement/) | Generate → Evaluate → Improve loop for higher-quality output | ❌ None |

## Install

### Via npx (recommended)

```bash
# Install all skills
npx skills add dylanfeltus/skills

# Install a specific skill
npx skills add dylanfeltus/skills --skill visual-qa
```

Auto-detects your agent (Claude Code, OpenClaw, Codex, Cursor, etc.)

### Manual

1. Copy the skill folder into your agent's skills directory
2. Reference the `SKILL.md` in your system prompt or project instructions
3. The agent follows the workflow and instructions defined in the skill

Each skill includes:
- `SKILL.md` — Full instructions the agent reads (trigger conditions, API details, error handling, output format)
- `README.md` — Human-facing docs

## License

MIT — see [LICENSE](./LICENSE).

## Contributing

More skills coming soon. Follow [@dylanfeltus](https://twitter.com/dylanfeltus) for updates.

---

*Built by [Stratus Labs](https://stratuslabs.io)*
