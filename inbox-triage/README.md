# inbox-triage

Triage an inbox by urgency, draft replies in the user's voice, and produce a digest readable in under a minute. Drafts only — it never sends.

## Installation

Copy the `inbox-triage` folder into your agent's skills directory.

## What's Inside

- **5-category taxonomy** — urgent / action-needed / FYI / low-priority / noise, each with concrete signals and an explicit "NOT urgent just because" list
- **Automated-email override table** — CI failures, monitoring alerts, receipts and calendar reminders default low and escalate only on the specific signal that matters
- **Reply patterns** — seven common scenarios, a style-calibration table, and a pre-save quality checklist
- **Red flags list** — mail that gets summarized but never drafted (legal, compensation, interpersonal conflict)
- **Digest format** — grouped by required action, with a 60-second read budget and defined edge cases

## Design Notes

**It never sends.** Not an unenforced promise: the Gmail MCP connector exposes `create_draft` but no send tool, so draft-only is a property of the tool surface. The user reviews and sends from their own client.

**It doesn't inflate urgency.** Most triage tooling over-flags, because a false urgent looks more useful than a false FYI. That's backwards — once everything is urgent, nothing is. The taxonomy spends most of its detail on reasons *not* to escalate.

**It doesn't keep your mail.** Summaries and metadata only. Full message bodies are never written to notes, files, or memory.

## Usage Examples

### Morning triage
> "Anything important in my inbox?"

Classifies recent unread mail, alerts on anything urgent, and returns a grouped digest.

### Prepare responses
> "Draft replies for anything that needs one"

Writes drafts for Action Needed mail, and flags the ones needing the user's own judgment instead.

### Catch up after time away
> "I've been out three days — what did I miss?"

Widens the window, leads with urgent, and rolls the rest up by category.

## Requirements

One of:

- **Gmail MCP connector** (recommended) — `search_threads`, `get_thread`, `create_draft`, and the label tools
- **IMAP CLI** such as [himalaya](https://github.com/soywod/himalaya), for Outlook, Fastmail, or other providers

Configure VIP senders, excluded labels, reply style, and digest time before the first run — see the `Configure This` block in `SKILL.md`. Sender-based urgency is guesswork without a VIP list.

## License

MIT
