# Inputd pointer reverse-sync source checkpoint — 2026-08-23

This is a source/build checkpoint, not a fresh QEMU installation claim.

## Source

- Repository: `regolith-inputd`
- Branch: `rahul/inputd-touchpad-lintian-reconciled-20260811`
- Commit: `e8fce66a60cd2abce7c6764a11cbdc354457a9b9`
- Vendoring parent: `e3fbd5c`
- Keyboard/input-source parent: `b07ea315`

`CosmicMouseHandler::sync_from_sway_input` now persists Sway/libinput
`accel_speed` and `natural_scroll` values to COSMIC `input_default` while
preserving unrelated fields. Missing values are left unchanged.

## Verification

```text
CARGO_NET_OFFLINE=true cargo test --all-features --offline  55 passed
cargo fmt --check                                         PASS
git diff --check                                           PASS
CARGO_NET_OFFLINE=true VENDOR=1 dpkg-buildpackage -us -uc -b PASS
```

Exact package artifact:

```text
regolith-inputd_0.4.1-2-1regolith-resolute_e8fce66_amd64.deb
SHA-256: 650bd6f38bf67a08e140fa566aff4e7c63b2a41fc2cc60b04aada670a420823b
```

The strict proposal ledger remains **5/12 fully met, QEMU-only**. The exact
package still needs installation and cold-login validation in the combined
QEMU tuple before runtime criteria are promoted.
