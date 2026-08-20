# Correction: the displayd apply-builder "complete, 81 tests" claim doesn't hold up

Date: 2026-08-19

## Why this was checked

Next item on today's prioritized proposal work-list was "wire displayd's
existing apply-builder through the observer-thread command channel,"
described in `01_Proposal_Alignment.md` as a small integration step on top
of a complete, tested apply builder (source commit `c45ee725`, "passed 81
tests"). Before starting implementation, a read-only research pass was run
to pin down the exact files and confirm the scope — standard practice
before any TDD implementation task, and specifically valuable here since
acting on an inaccurate scope estimate would have meant either
underestimating a real feature-implementation task as a quick fix, or
building on code that was never actually verified.

## What was actually found

**Commit `c45ee725` does not exist.** Checked every git repository under
`/Users/rahul/Desktop/Gsoc` (82 repos/worktrees, including every
`regolith-displayd`-related worktree, `.tmp/`, `.worker-scratch/`, and
`audit-notes/` copy) with `git log --all` and `git cat-file -t` against
the full hash from `tasks/todo.md`
(`c45ee725dd7f8077853cd4ef3425fa9de4c0b08`). No repo has this object. No
proof note anywhere mentions it or the 81-test claim either.

What exists instead: an **unapplied patch file**,
`/Users/rahul/Desktop/Gsoc/displayd.patch`, targeting
`.../regolith-displayd/.worktrees/cosmic-displayd-dbus-apply-20260818/src/wayland_observer.rs`
— a worktree path that doesn't exist on this machine. A materialized copy
of the resulting file sits loose and ungitted at
`/Users/rahul/Desktop/Gsoc/wayland_observer.rs`. The functional
description in the proposal doc (output-management objects retained, head
coverage validated, mode/position/transform/scale requests constructed,
succeeded/failed/cancelled handling) does match what this patch/file
contains — `WaylandApplyHandle::apply_profile`,
`ObserverCommand::ApplyProfile`, `apply_profile_command()` are real
symbols in it. But **it has zero accompanying tests**, and it was never
applied to or committed in any actual source tree. The "81 tests passing"
claim doesn't correspond to anything verifiable on disk.

## The real, currently-committed state

The actual `DisplayServer` D-Bus interface
(`.worker-scratch/displayd-44660e8/src/lib.rs`,
`#[dbus_interface(name = "org.gnome.Mutter.DisplayConfig")]`, method
`apply_monitors_config`) is entirely Sway/kanshi-based: validates a
serial, writes a kanshi profile, reloads kanshi, refreshes via Sway IPC.
No COSMIC/Wayland path exists in it at all. The same file has:

```rust
pub fn cosmic_profile_apply_status() -> Result<(), &'static str> {
    Err("COSMIC profile apply is unavailable: the Wayland observer does not
    retain output-manager, head, or mode handles needed for
    create_configuration")
}
```

A hardcoded stub, never called from `apply_monitors_config`. One existing
test (`lib.rs:956`) just asserts this stub returns `Err` — accurate today,
but it will need replacing once real work starts here.

## Why this is more than "routing" work

Closing this gap for real means three separate things, not one:

1. **Reconciling the patch against a real source tree.** The closest
   candidate base (`.worker-scratch/displayd-44660e8`, chosen for having
   58 real tests and the actual `DisplayServer`/stub code) differs from
   the patch's target file by roughly 300-500 lines — a real merge with
   likely conflicts, not a clean `patch -p1` apply.
2. **Writing tests from scratch.** None exist for the apply-builder logic
   itself. TDD on this project means red-green-refactor from zero, not
   extending existing coverage.
3. **A genuine architecture mismatch.** `apply_monitors_config` is `async`
   (zbus/tokio-driven). `WaylandApplyHandle::apply_profile` is synchronous
   and communicates via `std::sync::mpsc` with a polling-loop observer
   thread. Bridging those without blocking the async executor is real
   design work — a wrong bridge here could deadlock or stall the whole
   D-Bus service, not just fail one method call.

## Disposition

Per explicit user direction: corrected the record in
`01_Proposal_Alignment.md` (addendum added, original text left in place
per this project's convention of not rewriting history) and stopping here
for today rather than rushing greenfield feature work under time
pressure — exactly the kind of shortcut this project's proof-first,
TDD-mandatory rules exist to prevent. This does not change the strict
percentage: this criterion (Criterion 6/7, display persistence /
native-Settings-driven apply) was already `Partial`. The correction is
that its remaining gap is real feature implementation, not the "routing"
step previously recorded — scope grew, not the ledger.

## If picked up later

Recommended starting point: `.worker-scratch/displayd-44660e8` as the base
(most real tests, actual `DisplayServer`/stub present). First step should
be writing a failing test asserting `apply_monitors_config` calls into a
COSMIC apply path when the backend is COSMIC (mirroring the existing
Sway-path tests around `lib.rs:859-1222`), then reconciling
`displayd.patch`'s logic into `wayland_observer.rs` in that same worktree,
then solving the async/sync bridge — in that order, not patch-first.
