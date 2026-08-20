# displayd COSMIC apply wiring: closed, verified, PR opened

Date: 2026-08-20

## What this closes

The genuine remaining gap from the `c45ee725` apply-builder commit
(confirmed real and accurate tonight, after an earlier false correction —
see `2026-08-20-displayd-claim-re-correction.md`): `apply_monitors_config`
had no path to actually call `.apply()`/`.test()` on a built
`OutputConfigurationRequest`. A first attempt at this wiring correctly
stopped when it hit a real architecture fork — `05_Testing_Proof/2026-08-20-displayd-wiring-design-fork.md`
— rather than guessing. The user resolved that fork: add `calloop`.

## What was built

`calloop` + `calloop-wayland-source` added as dependencies. The observer
thread's previous bare `queue.blocking_dispatch(state)` loop is now a
`calloop::EventLoop` with two sources: the existing Wayland connection
(via `WaylandSource`), and a new inbound channel carrying apply requests
from the async D-Bus side. `DisplayServer` gained a `cosmic_desktop` flag
and a `WaylandApplyHandle` (both set explicitly via builder methods, not
read from an env var inside the async method, to avoid racy parallel-test
behavior). `apply_monitors_config` branches to the COSMIC path before any
Sway-connection check when the flag is set, reaching the calloop-bridged
thread via `tokio::task::spawn_blocking`.

Three commits on `rahul/cosmic-apply-monitors-config-wiring-20260820` (off
the real `c45ee725`, on `Rahul-2k4/regolith-displayd`):
`1e3f9bb` (deps), `5f664f2` (calloop bridge), `8d66519` (D-Bus wiring).

## Independent verification (not just trusting the worker's report)

- `cargo test --all` in a fresh Docker container: 65 lib tests + main.rs
  tests pass. One pre-existing test needs a live D-Bus session bus —
  confirmed independently by checking out `c45ee725`'s unmodified files
  into the same container and re-running it there: identical failure,
  confirming it is not a regression from this change.
- `cargo fmt --check`: clean (rustfmt component installed fresh in the
  container, run directly, not assumed).
- Git identity on all three commits confirmed:
  `Rahul Tripathi <rahultripathi7009@gmail.com>`.
- Diff shape reviewed: `Cargo.toml`/`Cargo.lock` (2 new deps),
  `wayland_observer.rs` (+447, the calloop bridge + 5 new tests),
  `lib.rs` (+312, the D-Bus wiring + 5 new tests), `main.rs` (+16,
  startup wiring) — sensible, scoped, no unrelated changes.

## PR

[Rahul-2k4/regolith-displayd#1](https://github.com/Rahul-2k4/regolith-displayd/pull/1),
humanized description, full RED/GREEN evidence and scope limits included.

## What this does not prove

Unit-level only. No live QEMU guest, no real D-Bus caller, no actual
COSMIC compositor has exercised this path end to end. `main.rs` compiles
and its tests pass with the new wiring attached, but nothing runs it
against a live session. That live verification is the natural next step
if this criterion is to move further — this PR closes the "no path
exists at all" gap, not the "proven working on a real compositor" gap.

## Ledger

Strict ledger unchanged: **62-68%, 5/12**. This is real, reviewed,
verified progress on an already-`Partial` criterion (6/7), not a
promotion to `Met` — that would need the live verification noted above.
