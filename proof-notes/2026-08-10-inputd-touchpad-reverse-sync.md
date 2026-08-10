# `regolith-inputd` touchpad reverse-sync candidate - 2026-08-10

## Source and model

- Inputd source commit: [`24c7ec2`](https://github.com/Rahul-2k4/regolith-inputd/commit/24c7ec2be99b9215e98ed2f5a83b9cc8b015d853)
- Inputd branch: [`rahul/inputd-touchpad-reverse-sync-20260810`](https://github.com/Rahul-2k4/regolith-inputd/tree/rahul/inputd-touchpad-reverse-sync-20260810)
- Voulage model commit: [`7e7e5b8`](https://github.com/Rahul-2k4/voulage/commit/7e7e5b86d02fd9f374d891cceeb38a38cc683b3d)
- Target: Ubuntu Resolute amd64, unstable stage

The candidate adds COSMIC touchpad reverse-sync for `accel_speed` and
`natural_scroll`. It reads and updates only `input_touchpad`, preserves the
other touchpad fields, and leaves `input_touchpad_override` independent. A
watcher guard prevents a Sway-originated config write from immediately being
sent back to Sway.

## Source verification

- `cargo fmt --check`: passed
- `cargo test --locked --no-default-features --features cosmic`: **46 passed**
- `cargo test --locked --all-features`: **49 passed**
- `bash tests/regolith-systemd-inputd.sh`: passed
- `git diff --check`: passed

The change is isolated to `src/cosmic.rs` on the candidate branch. It was not
merged into the frozen inputd tuple or an upstream default branch.

## Voulage artifact

- Package: `regolith-inputd`
- Version: `0.4.1-1-1regolith-resolute`
- Architecture: `amd64`
- Package SHA-256:
  `29183a8b6f76297e9976266bd6cff467c2eff8ac65053af8f77cbf1a7cf799d3`
- Source `.dsc` SHA-256:
  `11d422a3b18db828e6c68c66a974a3b59eb51fa578da8bcfae326e612c1bd723`
- Binary `.changes` SHA-256:
  `e0986108885bebcf94ef18a9f67a10ea270f7ddc94b2a5a371caf687a29b7ac3`
- Source `.changes` SHA-256:
  `6e19c084839f9b96940fee0be1383457043cd14c38b299b6424b1435a9a9093b`

The package contains `/usr/bin/regolith-inputd` and
`regolith-init-inputd.service`. Voulage Lintian reports two warnings:
`debug-file-with-no-debug-symbols` for the debug package and `no-manual-page`
for the daemon. The artifact is unsigned and is not a release publication.

## QEMU package and rollback proof

1. Normalized the disposable guest to the saved baseline package. Its binary
   SHA-256 was
   `a81fb59d0ea754e942d1e561039799afd2107fa087ff0bc7bbe7bc8ab981ce21`.
2. Installed the candidate package and rebooted the guest.
3. Started a fresh COSMIC login through the visible greetd path.
4. Verified the candidate binary SHA-256
   `2990408d05204a3c58703e30395bf868ae66a292ff6c5bf95c04813be5d978d1`,
   clean `dpkg --audit`, clean `dpkg -V`, active COSMIC target-owned inputd
   and displayd helpers, `Result=success`, and `NRestarts=0` for inputd.
5. Reinstalled the saved baseline package, rebooted, logged in again, and
   verified the baseline binary hash, clean package checks, active helpers,
   and zero inputd restarts.

This proves candidate package installation and session health in QEMU. The
guest exposes virtual pointer devices and no `type:touchpad` input, so the
reverse-sync code was not exercised against a physical touchpad. Hardware,
live touchpad reverse-sync, signing, canonical publication, and mentor
acceptance remain open.
