# inputd touchpad + lintian reconciliation (2026-08-11)

Task C1 from `docs/superpowers/plans/2026-08-10-gsoc-final-closure.md`.

Remote Linux workspace: `$WORKSPACE/regolith-inputd`.
Push remote: `rahul` → https://github.com/Rahul-2k4/regolith-inputd.git

## Before (split confirmed)

Commands:

```bash
git merge-base --is-ancestor 24c7ec2b b380c9aa; echo "FIX_IN_PIN=$?"
git merge-base --is-ancestor 24c7ec2b HEAD; echo "FIX_IN_HEAD=$?"
```

Results:

| Check | Value | Meaning |
| --- | --- | --- |
| `FIX_IN_PIN` | `1` | touchpad fix `24c7ec2b` is **not** an ancestor of lintian pin `b380c9aa` |
| `FIX_IN_HEAD` | `1` | touchpad fix `24c7ec2b` is **not** an ancestor of then-HEAD |

Commits at check time:

- `24c7ec2` — `feat(inputd): persist COSMIC touchpad reverse sync`
- `b380c9a` — `debian: fix inputd lintian warnings`
- then-HEAD was `cd1c2cd` on `codex/inputd-touchpad-deterministic-coverage-20260810` (also without the fix as ancestor)

`git merge-base 24c7ec2b b380c9aa` → `cd1c2cd1056bfb51a920f2a8794ccbf89e953489`

## Reconciliation

1. Branched from lintian-clean pin:

   `git checkout -b rahul/inputd-touchpad-lintian-reconciled-20260811 b380c9aa`

2. **RED (TDD):** `CosmicTouchpadHandler::sync_from_sway_input` was no-op (`debug!` + `Ok(())`) at `src/cosmic.rs` ~476–482.

3. Cherry-pick: `git cherry-pick 24c7ec2b` — **clean** (no conflicts).

   New commit: `e641b434c76c70e9a21e492adea577607e096d03`

4. **GREEN:** `accel_speed` / `natural_scroll` present in touchpad reverse-sync path; three `fn sync_from_sway_input` definitions remain (mouse no-op, touchpad real, keyboard stub).

## After

| Item | Value |
| --- | --- |
| Branch | `rahul/inputd-touchpad-lintian-reconciled-20260811` |
| Tip SHA | `e641b434c76c70e9a21e492adea577607e096d03` |
| Parent | `b380c9aa8f75b8d2da657b58b459a861c3a5d56b` (lintian) |
| Cherry-pick of | `24c7ec2b` (content; new SHA because cherry-pick ≠ merge) |
| `FIX_IN_PIN` still | `1` (expected: original fix commit never became ancestor of `b380c9aa`) |
| Fix on branch tip | yes (content via `e641b43`) |

Push URL (PR create link from remote):

https://github.com/Rahul-2k4/regolith-inputd/pull/new/rahul/inputd-touchpad-lintian-reconciled-20260811

Branch on fork:

https://github.com/Rahul-2k4/regolith-inputd/tree/rahul/inputd-touchpad-lintian-reconciled-20260811

## Gate results

| Gate | Result |
| --- | --- |
| `cargo fmt --check` | `FMT=0` |
| `git diff --check` | `WS=0` |
| `cargo test --no-default-features --features cosmic` | `ok. 46 passed; 0 failed` |
| `cargo test --all-features` | `ok. 49 passed; 0 failed` |
| `cargo test` (default/gnome) | `ok. 22 passed; 0 failed` |

## Honest limits

- Physical touchpad reverse-sync on real hardware remains **unproven**.
- This is source + unit-test reconciliation only; QEMU/session runtime proof is a later gate.
- Do not claim laptop/hardware touchpad persistence from this note alone.
