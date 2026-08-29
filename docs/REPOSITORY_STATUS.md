# Repository and branch status

Checked locally on **2026-08-29**. This file records readiness honestly; it
does not publish, create, or merge a pull request.

## Readiness labels

- **Existing PR:** a fork PR is already visible, but it may not represent the
  newest local candidate.
- **Source candidate:** useful local commits exist, but the branch still needs
  review, rebase, packaging, or runtime proof.
- **Not PR-ready:** a reviewer found a correctness gap, the work is local-only,
  or the exact public branch cannot be verified yet.

## Current inventory

### `regolith-session`

- Local candidate: detached commit `443148a`, with session-helper cleanup and
  target-query handling.
- Public state: fork PR #1 is open; older PR #3 is merged and #2 is closed.
- Readiness: **Source candidate**. Do not push the detached commit yet.

### `regolith-inputd`

- Local candidate: `packaging/inputd-package-metadata` at `3351cec`.
- Local state: uncommitted source files and an untracked source archive are
  also present in that worktree.
- Public state: no fork PR row was returned by the current query.
- Readiness: **Not PR-ready**. Fix config ownership and Debian test-hook
  coverage first.

### `regolith-displayd`

- Local candidate: refresh-rate source commit
  `21e4553618cb8f0d21e46bac13a37451cb489059`.
- Public state: fork PR #1 is open for the earlier calloop apply wiring.
- Readiness: **Existing PR**. The refresh candidate still needs runtime
  persistence proof.

### `cosmolith`

- Local candidate: `fix/startup-xkb-events-atomic` at `3f39153`, two commits
  ahead of its tracked remote.
- Public state: the current fork query showed one merged PR and no open PR.
- Readiness: **Not PR-ready**. Complete Cargo.lock Git-source coverage and
  Debian test-hook wiring first.

### `voulage`

- Local candidate: fork `main` carries the current package model; additional
  repin work is on a separate branch.
- Public state: no fork PR row was returned by the current query.
- Readiness: **Source candidate**. Publication remains a maintainer action.

### `regolith-wm-config`

- Local/public reference: historical COSMIC/Kanshi candidate at `10225c05`.
- Readiness: **Historical evidence only**. Do not present it as release-ready.

## Current fork-query result

The live fork query returned:

- `regolith-session`: PR #1 open, PR #3 merged, PR #2 closed;
- `regolith-displayd`: PR #1 open;
- `cosmolith`: one merged PR, no open PR;
- `regolith-inputd` and `voulage`: no PR rows returned.

These PR rows came from successful read-only `gh pr list` calls during this
review. A later branch-head refresh failed because GitHub DNS was unavailable,
so remote branch ancestry still needs a fresh check before any push.

Older notes that name cosmolith PRs `#17`, `#18`, and `#19` are not used as
current public claims until their remote state is rechecked.

## Before creating fork-to-fork PRs

1. Give each accepted candidate a named branch, especially the detached
   `regolith-session` commit.
2. Rebase or verify ancestry against the fork's current default branch.
3. Resolve the inputd and cosmolith reviewer findings.
4. Run the Linux Cargo/Debian checks and the relevant QEMU proof.
5. Run the secret scan and inspect its result before any push.
6. Create PRs against the personal fork's default branch only after those
   checks. Change the base to upstream later, when the mentor approves.

No push, PR creation, merge, or upstream change is included in this status
file.
