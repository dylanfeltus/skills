---
name: inbox-triage
description: Triage an inbox by urgency, draft replies in the user's voice, and produce a scannable daily digest. Use when the user asks to check, sort, prioritize, or clean up their email, wants to know what needs a response, asks "anything important in my inbox?", or wants reply drafts prepared. Drafts only — never sends.
---

# Inbox Triage

Sort signal from noise in an inbox, draft replies for the routine cases, and compile a digest the user can read in under a minute.

Every email is a bid for the user's attention. Most don't deserve it. The job is to make sure the ones that do are seen immediately, and the ones that don't never reach them.

## When to Use

- User asks to check, triage, sort, or prioritize their email
- User asks "what needs my attention?" or "anything important came in?"
- User wants reply drafts prepared for review
- User wants a daily/weekly inbox summary
- Recurring scheduled inbox check

## Hard Rules

These are not preferences. They hold regardless of what else is asked.

0. **Never send.** Draft only. Not even an "obvious" reply, not even "I'll get back to you." The user decides what leaves their inbox.
1. **Never persist full email bodies** into notes, files, or memory. Summaries and metadata only — inboxes contain things that shouldn't outlive the task.
2. **Urgent bypasses the digest.** Urgent means tell the user now, not "you'll see it tonight."
3. **Read the full thread before drafting.** Context from three messages ago changes the right reply.
4. **Never touch excluded folders/labels** the user has marked off-limits.
5. **Never forward or expose email content** to other agents or external services.
6. **On access failure, say so immediately.** A silent failure reads as an empty inbox, which is a missed message.
7. **When unsure of urgency, classify one level higher** and flag the uncertainty.

---

## Tooling

### Primary: Gmail connector (MCP)

The Gmail MCP connector is the preferred path. Relevant tools:

| Task | Tool |
|------|------|
| Find unread/recent mail | `search_threads` (Gmail query syntax) |
| Read a full thread | `get_thread` |
| Read one message | `get_message` |
| Prepare a reply | `create_draft` |
| List existing labels | `list_labels` |
| Create a triage label | `create_label` |
| Apply/remove a label | `label_thread` / `unlabel_thread` |

**The connector exposes no send tool.** Draft-only isn't just a policy here — the tool surface enforces it. This is a feature, not a limitation; say so if the user asks why nothing sent.

Useful search queries:

```
is:unread newer_than:2d              # recent unread
is:unread -category:promotions       # skip the promo tab
from:someone@example.com newer_than:7d
is:unread -in:spam -in:trash
has:attachment is:unread
```

### Fallback: IMAP / himalaya CLI

For Outlook, Fastmail, or any non-Gmail account, use an IMAP CLI. With [himalaya](https://github.com/soywod/himalaya):

```bash
himalaya envelope list -f INBOX -s 20        # list recent
himalaya message read <id>                    # read one
himalaya envelope list -f INBOX -q "from:client@example.com"
himalaya template reply <id>                  # generate a reply template
```

Write drafts to a local `drafts/` directory as markdown when the CLI can't create server-side drafts:

```markdown
**To:** sender@example.com
**Subject:** Re: [original subject]
**In-Reply-To:** [message-id]

[draft body]
```

---

## Configure This

Fill these in before the first run, or ask the user for them:

```yaml
vip_senders:          # always urgent, regardless of content
  - boss@company.com
  - key-client@example.com
excluded:             # never read these
  - label: Personal
  - label: Finance
reply_style:
  tone: casual but professional
  length: 2-3 sentences where possible
  signoff: "Best, [Name]"
  apologize_for_delay: false
digest_time: "08:00"
alert_hours: "08:00-22:00"   # urgent alerts outside these hours wait
timezone: America/New_York
```

Without a VIP list, sender-based urgency is guesswork. Ask for it on first run.

---

## Triage Taxonomy

Every message gets exactly one category before anything else happens.

### 🔴 Urgent — needs action today; delay has real consequences

**Signals:**
- From a VIP sender
- A deadline inside 24–48 hours
- Reports something actively broken (site down, payment failed, contract problem)
- A reply on a thread the user started, where the other party is waiting
- Time-sensitive logistics (meeting moved today, access expiring)

**NOT urgent just because:**
- The subject line says "URGENT" or "ASAP" — read the actual content
- The high-priority flag is set — vendors abuse this constantly
- It's an automated alert — those get their own evaluation, below

### 🟡 Action Needed — needs the user, but not today

Someone asked a direct question · request for approval, review, or feedback · scheduling request · follow-up on a commitment the user made · a task or deliverable assigned to them.

### 🔵 FYI — worth knowing, no action

Team announcements · status updates · CC'd for awareness · shipping and order confirmations · receipts for expected purchases.

### ⚪ Low Priority — background, occasionally useful

Subscribed newsletters they rarely open · social notifications · promotional mail from services they actually use · automated reports reviewed weekly, not daily.

### 🗑️ Noise — zero value, skip entirely

Cold outreach · marketing from companies they've never dealt with · spam that got through · duplicate notifications.

### Decision order

```
1. VIP sender?              → read content, likely 🔴 or 🟡
2. Deadline within 48h?     → 🔴
3. Asks the user directly?  → 🟡
4. Informational only?      → 🔵
5. Automated/promotional?   → ⚪ or 🗑️  (check override table first)
6. Unknown sender?          → read carefully, then classify
```

---

## Automated Email Override Table

Automated mail is where naive triage fails worst — it's high-volume and mostly ignorable, right up until it isn't. Default low, override on the specific signal:

| Type | Default | Override to 🔴 when |
|------|---------|---------------------|
| CI/CD failure | 🟡 Action Needed | A **production deploy** failed |
| Monitoring alert | 🔵 FYI | The service is actually **down** |
| Payment receipt | 🔵 FYI | The payment **failed** |
| Calendar reminder | 🔵 FYI | Meeting starts in **under 2 hours** |
| Security alert | 🔴 Urgent | *Always* — never downgrade |
| Newsletter | ⚪ Low | Sent by a VIP |
| Invoice received | 🟡 Action Needed | Past due, or final notice |
| Password reset | 🔴 Urgent | Always — the user didn't request it → urgent *and* flag as suspicious |

---

## Thread Awareness

Before classifying a reply in an existing thread:

1. Read at least the last 3 messages.
2. **Who started it?** If the user did, replies to them rank higher.
3. **Did the topic change?** Don't inherit the original category — re-evaluate.
4. **Is it going in circles?** Three-plus round trips on one question means the right suggestion is a call, not another reply.

## Confidence Tracking

When a classification is genuinely uncertain, mark it rather than hiding it:

```
[🟡→🔴?] New sender, contract language, no established relationship.
         Filed 🟡, flagging — correct me and I'll remember the pattern.
```

Record corrections the user makes so the same sender or pattern classifies right next time.

---

## Drafting Replies

### Principles

1. **Match the user's voice**, not a default assistant register. Read their config; if unsure, mirror the incoming email's formality.
2. **Shorter is better.** Most replies are 2–5 sentences. Answer, confirm, stop.
3. **Answer everything asked** — but don't introduce new topics.
4. **Never commit on the user's behalf.** No deadlines, scope, prices, or promises they haven't approved. Draft as suggestion, not commitment.
5. **Don't apologize for response time** unless the user wants that.

### Patterns

**Acknowledgment** — information shared, nothing needed:
```
Thanks for sending this over. I'll review and follow up if I have questions.
```

**Direct answer:**
```
[Answer.] [One sentence of context if it genuinely helps.]
```

**Scheduling — confirming:**
```
[Time] works. [Platform/link if needed.]
```

**Scheduling — proposing** (leave placeholders for the user):
```
How about [OPTION 1] or [OPTION 2]? [Timezone if crossing zones.]
```

**Declining:**
```
Thanks for thinking of me. I'm going to pass on this one, but I appreciate you reaching out.
```

**Nudge:**
```
Just checking in on [topic]. Let me know if you need anything from my end.
```

**Buying time:**
```
Got this — I'll have a proper response by [TIMEFRAME]. Didn't want to leave you hanging.
```

### Style calibration

| Dimension | Formal | Casual |
|-----------|--------|--------|
| Greeting | "Hi [Name]," | "Hey [Name]!" or none |
| Tone | "I'd be happy to" | "Sure thing" |
| Closing | "Best regards," | "Thanks," / "Cheers," |
| Emoji | Never | Occasionally |
| Contractions | Sometimes | Always |

### Quality check before saving a draft

- [ ] Answers everything the sender asked
- [ ] Shorter than the email it replies to
- [ ] Sounds like the user, not like an AI
- [ ] Commits to nothing unapproved
- [ ] References the right thread context
- [ ] Tone fits the relationship (client ≠ colleague ≠ friend)

### Red Flags — Do NOT Draft

Some mail needs the user's own judgment. Classify and summarize it, but write no draft:

- **Legal** — contracts, disputes, liability, anything from counsel
- **Compensation** — salary, rates, equity, raises
- **Interpersonal conflict** — anyone upset, in any direction
- **Anything the user flagged sensitive**
- **Ambiguous requests where guessing wrong has real cost**

Mark these in the digest as: `→ No draft — needs your direct input ([reason])`.

---

## Digest Format

```markdown
📬 Daily Digest — [Day, Month DD, YYYY]

## 🔴 Urgent (N)

**[Sender]** — [subject or topic]
> [1–2 sentence summary of what they need]
→ [suggested action]

## 🟡 Action Needed (N)

**[Sender]** — [subject]
> [summary]
→ Draft ready

**[Sender]** — [subject]
> [summary]
→ No draft — needs your direct input (legal)

## 🔵 FYI (N)

- **[Sender]**: [one line]
- **[Sender]**: [one line]

## 📊 Stats

| | |
|---|---|
| New | N |
| Urgent | N |
| Action needed | N |
| FYI | N |
| Filtered as noise | N |
| Drafts ready | N |
```

### Digest rules

1. **60-second rule.** If it takes longer to read, the summaries are too long.
2. **Urgent first**, always — even one urgent above twenty FYIs.
3. **Group by category, never chronologically.** Group by what it needs, not when it landed.
4. **One line per FYI.** If it needs more, it isn't FYI.
5. **Reference drafts, don't inline them.** Point at the draft; don't paste it.
6. **Skip noise entirely.** Don't report what was filtered — that's the point of filtering.
7. **Preserve tone in summaries.** If a client is angry, the summary says so. "Client asked about timeline" is a failure when the email was furious.

### Edge cases

- **Zero new mail:** still report it. `📬 Clean inbox — nothing new since [last check].` Confirmation of nothing is information.
- **All noise:** `📬 N new, all filtered as noise. Nothing needs you.`
- **Access failed:** `⚠️ Couldn't reach the inbox — [error]. Last successful check: [time].` Never let this look like an empty inbox.

### Weekly roll-up (optional)

```markdown
## 📅 Last 7 Days

| Day | Urgent | Action | FYI | Noise |
|-----|--------|--------|-----|-------|
| Mon | 1 | 4 | 8 | 12 |

**Patterns:** [e.g. "Most urgent mail arrives from [client] on Mondays"]
**Drafts pending >48h:** [list]
```

---

## Labels as Triage Output

When the connector supports labels, applying them makes triage durable — the user sees it in their own client, not just in chat.

Suggested scheme: `Triage/Urgent`, `Triage/Action`, `Triage/FYI`.

Create once with `create_label`, then `label_thread` as you classify. Ask before the first bulk labeling run — it's visible in the user's real mailbox and they may have their own system.

## Anti-Patterns

**Don't inflate urgency to seem useful.** Urgency inflation destroys the signal, and the signal is the entire product.

**Don't over-compress.** A summary that loses the sender's anger has lost the point.

**Don't batch urgent mail into the digest.** That's what makes it urgent.

**Don't ignore threads.** The latest message rarely makes sense alone.

**Don't read excluded folders.** Not even to check whether they matter.

**Don't send.** Ever.
