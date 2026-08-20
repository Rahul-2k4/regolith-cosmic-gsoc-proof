# Re-correction: the displayd apply-builder claim was accurate; my "correction" was the error

Date: 2026-08-20

## What happened, in order

1. 2026-08-19: a research pass claimed source commit `c45ee725` (the
   apply builder, "81 tests passing") didn't exist anywhere, and that
   what actually existed was an untested, unapplied patch file. This was
   written up as a correction in `01_Proposal_Alignment.md` and its own
   proof note.
2. 2026-08-20: while independently scoping the same wiring task for real
   TDD implementation, a different worker's setup step (finding a
   pushable git remote to land the work on) surfaced
   `origin/rahul/cosmic-live-apply-20260818` on the real
   `Rahul-2k4/regolith-displayd` fork — and its tip commit is exactly
   `c45ee725dd7f8077853cd4ef3425fa9de4c0b08a`.
3. Verified directly, not assumed: `git show c45ee725...:src/lib.rs` etc.
   confirms the commit is real, committed, and pushed. Counted `#[test]`
   and `#[tokio::test]` attributes across all six `.rs` files at that
   commit by hand: `lib.rs` 37, `main.rs` 25, `modes.rs` 2, `monitor.rs`
   7, `resources.rs` 0, `wayland_observer.rs` 10 — sum: **81**, exactly
   matching the proposal doc's original claim.

## Why the 2026-08-19 search missed it

That research pass checked every git repository under
`/Users/rahul/Desktop/Gsoc` — but "every repository" meant every local
worktree/clone/scratch directory already present on this Mac. It never
ran `git fetch` against the actual GitHub remotes those worktrees point
to, so any commit that existed only on an unfetched remote branch (not
yet pulled down to a local worktree) was invisible to that search,
indistinguishable from a commit that genuinely doesn't exist anywhere.
The commit had been pushed to GitHub but no local worktree happened to
have fetched that specific branch yet.

**Lesson for this project going forward:** when a proof-note or proposal
claim cites a commit hash that can't be found locally, the correct next
step before declaring it fabricated is to `git fetch --all` (or fetch the
specific candidate remotes) across the relevant repo's known forks, not
just search what's already checked out. A missing commit in local
worktrees is not the same as a missing commit in the project's actual git
history.

## What was and wasn't wrong in the 2026-08-19 correction

- **Wrong:** "commit c45ee725 does not exist" — false, it exists and is
  pushed.
- **Wrong:** "no tests accompany it, 81 tests is unverifiable" — false,
  the count is exactly 81.
- **Correct, and unaffected by this re-correction:** the wiring gap
  itself. `c45ee725` is the tip of its branch — nothing after it touches
  `apply_monitors_config`, `cosmic_desktop`, or `WaylandApplyHandle`. The
  D-Bus method there is still Sway/kanshi-only. The original proposal
  doc's own final sentence — "the remaining implementation boundary is
  routing the existing DisplayServer D-Bus method through the
  observer-thread command channel; it is not claimed as complete yet" —
  was accurate the whole time.

## Consequence for tonight's TDD implementation work

A separate worker was dispatched earlier tonight to implement this wiring
via TDD, working from the *false* premise that no tested apply builder
existed. It built real, reviewed, working logic (a `cosmic_desktop` flag,
an `apply_monitors_config_cosmic` method, a `tokio::task::spawn_blocking`
bridge to the synchronous apply logic) — but on a disconnected scratch
git repository with no relationship to the real `regolith-displayd` fork,
reconciling against an unapplied patch file rather than the real,
already-tested `c45ee725` commit. That work is not wasted — the design
(the bridge pattern, the flag-based signal, the test structure) is sound
and directly reusable — but it needs to be re-landed against the actual
`c45ee725` commit on `rahul/cosmic-live-apply-20260818`, not the scratch
copy, before it can be committed or pushed anywhere real.

## Status

Correcting the vault record now (`01_Proposal_Alignment.md` updated with
this re-correction). Re-doing the wiring implementation against the real
branch is the next step, dispatched separately.
