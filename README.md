# Skills Library

A collection of reusable AI agent skills for research, intelligence gathering, design, and content creation. Drop a folder into your agent's skills directory and it just works.

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

### Design

| Skill | Description | Auth Required |
|-------|-------------|---------------|
| [motion-design-patterns](./motion-design-patterns/) | Framer Motion patterns — springs, staggers, layout animations, micro-interactions | ❌ None |
| [design-tokens](./design-tokens/) | Type scales, color palettes, spacing grids, WCAG contrast, dark mode derivation | ❌ None |
| [creative-direction](./creative-direction/) | Image prompt templates, model selection, anti-generic patterns | ❌ None |
| [visual-qa](./visual-qa/) | Screenshot review against design intent using vision models | ❌ None |

### Content & Quality

| Skill | Description | Auth Required |
|-------|-------------|---------------|
| [recursive-improvement](./recursive-improvement/) | Generate → Evaluate → Improve loop for higher-quality output | ❌ None |

## How to Use

1. Copy the skill folder into your agent's skills directory
2. Reference the `SKILL.md` in your system prompt or project instructions
3. The agent follows the workflow and instructions defined in the skill

Each skill includes:
- `SKILL.md` — Full instructions the agent reads (trigger conditions, API details, error handling, output format)
- `README.md` — Human-facing docs

## Contributing

More skills coming soon. Follow [@dylanfeltus](https://twitter.com/dylanfeltus) for updates.

---

*Built by [Stratus Labs](https://stratuslabs.io)*
