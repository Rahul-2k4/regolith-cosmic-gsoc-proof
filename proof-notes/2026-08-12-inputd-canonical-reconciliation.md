# Canonical inputd branch reconciliation

Date: 2026-08-12

## Ancestry

The keyboard-routing head [`271bc2a`](https://github.com/Rahul-2k4/regolith-inputd/commit/271bc2a)
and the remote touchpad/lintian head [`5831628`](https://github.com/Rahul-2k4/regolith-inputd/commit/5831628)
diverged at [`e641b43`](https://github.com/Rahul-2k4/regolith-inputd/commit/e641b43).
The touchpad head contained three commits not present in the keyboard head;
the keyboard head contained the routing commit not present in the touchpad
head.

## Reconciled source of truth

The new branch [`rahul/inputd-cosmic-canonical-20260812`](https://github.com/Rahul-2k4/regolith-inputd/tree/rahul/inputd-cosmic-canonical-20260812)
starts from `5831628` and cherry-picks `271bc2a`, producing
[`c658754`](https://github.com/Rahul-2k4/regolith-inputd/commit/c658754).
The Voulage closure branch pins `regolith-inputd` to this exact commit.

## Verification

- `cargo fmt --check`: passed
- `cargo test --features cosmic`: 51 passed, 0 failed
- `cargo test --all-features`: 51 passed, 0 failed
- `git diff --check`: passed

This resolves the branch-fragmentation finding. It is source and test proof;
it does not claim a new live input-device runtime matrix.
