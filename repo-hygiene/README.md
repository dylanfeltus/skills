# repo-hygiene

Audit a repository for stale branches, abandoned PRs, forgotten issues, and README drift. Reports recommendations with the evidence behind each one.

## Installation

Copy the `repo-hygiene` folder into your agent's skills directory.

## What's Inside

- **Branch staleness detection** with a mandatory unmerged-commit safety gate
- **PR triage matrix** — abandoned / stale / blocked / ready / draft-forgotten / conflicted, each with a recommended action
- **Issue triage** that flags and never closes
- **README drift detection** — declared Node version, documented scripts, and env vars checked against what the repo actually contains
- **Dependency batching strategy** (without rebuilding Dependabot)

## Design Notes

**"Merged" is not enough to delete a branch.** The gate is `git log origin/$DEFAULT..$BRANCH` returning empty. Commits pushed *after* a merge are common, and they're exactly the work people lose to enthusiastic cleanup. Branches with unmerged commits are never listed alongside safe ones.

**It doesn't assume `main`.** The default branch is resolved first and used throughout. `master`, `develop`, and `trunk` are all still in the wild.

**It never closes issues.** An issue open for 18 months may still be valid. The skill flags for triage and leaves the judgment to a human.

**It doesn't rebuild Dependabot.** If no dependency automation is configured, the recommendation is to enable it. What the skill keeps is the batching strategy — patches together, majors separate — since one-PR-per-package is why dependency PRs get ignored.

## Usage Examples

### Full sweep
> "Clean up my repo"

### Branch focus
> "Which of my branches are safe to delete?"

### Docs check
> "Is my README still accurate?"

## Requirements

Either the `gh` CLI (authenticated) or GitHub MCP tools, plus local `git` for branch comparison. Examples use `gh`.

## License

MIT
