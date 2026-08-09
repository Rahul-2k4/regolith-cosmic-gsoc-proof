# `regolith-inputd` empty-layout guard

Date: 2026-08-10

The isolated inputd candidate is branch
`codex/inputd-touchpad-deterministic-coverage-20260810` at commit
`cd1c2cd1056bfb51a920f2a8794ccbf89e953489`, based on frozen source
`e32d0497f67fea94fb98f803c406c704191b741c`.

It changes `src/input_sources.rs` so an empty Sway `xkb_layout_names` vector
is ignored instead of indexing element zero and panicking. Two focused tests
cover the empty and non-empty cases.

Verification:

- `cargo fmt --check`: passed
- `cargo test --locked --all-features`: 46 passed
- focused `input_sources::tests`: 3 passed
- `git diff --check`: passed

This is source/test evidence only. The frozen installed package tuple still
uses `e32d049`; no Voulage model rebuild, package install, QEMU runtime proof,
or hardware claim is made for `cd1c2cd`.
