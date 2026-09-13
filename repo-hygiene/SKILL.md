---
name: repo-hygiene
description: Audit a repository for stale branches, abandoned PRs, forgotten issues, and README drift, then report cleanup recommendations with the evidence behind each one. Use when the user asks to clean up a repo, find stale branches or PRs, check repo health, or asks why their branch list is a mess. Flags and recommends — never force-pushes, merges, or closes.
---

# Repo Hygiene

Find the maintenance debt everyone agrees matters and nobody does: stale branches, abandoned PRs, forgotten issues, and READMEs that stopped matching the code.

**Recommend and wait is the default.** This skill identifies and reports. Deletion, closure, and merging are the user's calls unless they explicitly opt in.

## When to Use

- User asks to clean up or audit a repository
- User asks about stale branches, old PRs, or forgotten issues
- User asks "why do I have 40 branches?"
- Periodic repo health check
- Pre-release tidy-up

## Hard Rules

0. **Never force-push.** To anything, ever.
1. **Never delete a branch with unmerged commits.** Verify first — see below.
2. **Never merge a PR** without explicit instruction.
3. **Never close an issue.** Flag for triage; a human decides.
4. **Never assume the default branch is `main`.** Check.
5. **One repo at a time.** Finish the sweep before starting another.

## Setup

Verify the default branch before anything else — `master`, `develop`, and `trunk` are all still out there:

```bash
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
# or
git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
```

Store it as `$DEFAULT` and use it everywhere below. Either the `gh` CLI or GitHub MCP tools work; `gh` is shown here.

---

## 1. Branches

### Stale criteria

A branch is stale when **all** of these hold:

1. No commits in the last N days (default 30)
2. No open PR associated with it
3. Not protected or long-lived (`$DEFAULT`, `develop`, `staging`, `release/*`)

```bash
git fetch --prune
for b in $(git branch -r --format='%(refname:short)' | grep -v "origin/$DEFAULT$"); do
  last=$(git log -1 --format=%ci "$b")
  age=$(( ( $(date +%s) - $(git log -1 --format=%ct "$b") ) / 86400 ))
  echo "$age days | $last | $b"
done | sort -rn
```

### The check that matters

**Before recommending deletion of any branch**, confirm nothing would be lost:

```bash
git log origin/$DEFAULT..$BRANCH --oneline
```

**If this returns any commits, do not recommend deletion.** The branch contains work that never landed. "It was merged" is not sufficient — commits are routinely pushed *after* a merge, and those are exactly the ones people lose.

Full gate before recommending removal:

- [ ] `git log origin/$DEFAULT..$BRANCH` is empty
- [ ] No open PR references the branch
- [ ] Not referenced in an open issue or PR discussion
- [ ] Not in the user's configured exceptions

### Naming

Compare against the repo's own convention, inferred from the majority of recent branches — don't impose one.

| Convention | Violation |
|---|---|
| `feature/` prefix | `add-auth` (missing) |
| lowercase | `Feature/Add-Auth` |
| no spaces | `feature/add auth` |

Flag violations. Never rename — that breaks other people's checkouts.

---

## 2. Pull Requests

### Stale criteria

No activity — comments, commits, reviews — in N days (default 14), and CI is not pending.

```bash
gh pr list --state open --json number,title,author,updatedAt,isDraft,reviewDecision,mergeable \
  --limit 100 --jq '.[] | "\(.number)\t\(.updatedAt[:10])\t\(.reviewDecision // "none")\t\(.title[:50])"'
```

### Triage matrix

| Category | Criteria | Recommend |
|----------|----------|-----------|
| **Abandoned** | >30d silent, author unresponsive to review | Flag for closure |
| **Stale** | 14–30d silent | Comment asking for status |
| **Blocked** | Changes requested, no follow-up | Flag to author |
| **Ready** | Approved, CI green, unmerged | Flag to maintainer — this is the expensive one |
| **Draft forgotten** | Draft, >14d silent | Flag to author |
| **Conflicted** | Merge conflicts with `$DEFAULT` | Flag to author |

"Ready" deserves attention first. An approved, green, unmerged PR is finished work earning nothing.

### Stale PR comment template

```markdown
👋 No activity on this PR for {N} days.

- Still in progress? A comment or a push keeps it open.
- No longer needed? Please close it.
- Blocked? Let us know what's needed.

Automated hygiene check.
```

---

## 3. Issues

**Flag only. Never close.** An issue open 18 months might still be valid — it's accumulating guilt, not necessarily obsolescence, and that distinction is the maintainer's to make.

```bash
gh issue list --state open --json number,title,updatedAt,assignees,labels,milestone \
  --limit 100 --jq '.[] | select(.updatedAt < "'"$(date -d '90 days ago' +%Y-%m-%d)"'")'
```

| Status | Recommendation |
|--------|---------------|
| Stale, unassigned, unlabeled | Flag for triage — likely forgotten |
| Stale, assigned | Flag — assignee may have moved on |
| Stale, has milestone | Leave it; the milestone is context |
| Stale, `wontfix` | Suggest closure — still ask |

---

## 4. README Drift

Documentation rots silently. It's invisible until a new contributor follows it and nothing works.

```bash
# Node version claimed vs declared
grep -oiE 'node(\.js)? v?[0-9]+' README.md
jq -r '.engines.node // "not declared"' package.json

# Commands the README tells people to run vs ones that exist
grep -oE 'npm run [a-z:-]+' README.md | sort -u | sed 's/npm run //'
jq -r '.scripts | keys[]' package.json | sort

# Env vars documented vs exemplified
grep -oE '\b[A-Z][A-Z0-9_]{3,}\b' README.md | sort -u
[ -f .env.example ] && cut -d= -f1 .env.example | sort -u
```

Flag when:

- A version in the README doesn't match `package.json` / `.nvmrc` / `Dockerfile`
- The README references a script that no longer exists
- An env var is documented but missing from `.env.example` (or vice versa)
- Install instructions name a removed dependency
- Badges point at a renamed repo or a dead CI

---

## 5. Dependencies

Full dependency automation belongs to Dependabot or Renovate — don't rebuild it. If neither is configured, say so; that's the actual recommendation.

What's worth carrying is the **batching strategy**, because the default "one PR per package" is what makes people ignore dependency PRs entirely:

| Type | Risk | Strategy |
|------|------|----------|
| Patch (1.0.0 → 1.0.1) | Low | Batch all into one PR |
| Minor (1.0.0 → 1.1.0) | Medium | Batch related ones |
| Major (1.0.0 → 2.0.0) | High | One PR each, with a changelog link |

```bash
npm audit --json 2>/dev/null | jq '.metadata.vulnerabilities'
```

Critical or high vulnerabilities get surfaced immediately, not batched into the sweep summary.

---

## 6. Report

```markdown
## Repo Hygiene — [owner/repo] — [date]

Default branch: `[name]`

### Branches — N total
| Branch | Age | Merged | Unmerged commits | Recommend |
|--------|-----|--------|------------------|-----------|
| `old/thing` | 94d | ✅ | 0 | Safe to delete |
| `wip/feature` | 62d | ❌ | 3 | **Keep** — unmerged work |

### Pull Requests — N open
| # | Age | Status | Recommend |
|---|-----|--------|-----------|
| #42 | 38d | Approved, CI green | **Merge or close** — finished work sitting idle |

### Issues — N open, M stale
Flagged for triage (not closed): #12, #31, #44

### README Drift
- ⚠️ README says Node 18, `package.json` requires >=20
- ⚠️ `npm run build:prod` documented but not in scripts

### Dependencies
- No Dependabot/Renovate config — recommend enabling
- 2 high-severity advisories

### Summary
N branches safe to delete · M needing review · X PRs awaiting action
```

## Reporting Rules

1. **Every recommendation carries its evidence** — dates, commit counts, versions. "Stale branch" is an assertion; "94 days, 0 unmerged commits, no open PR" is a case.
2. **Separate safe from unsafe.** A branch with unmerged commits never appears in the same list as one without.
3. **Under two minutes to read.** The summary is the deliverable.
4. **Silence is fine.** A clean repo gets a short report, not manufactured findings.
