# Displayd mode-selection fix candidate - 2026-08-12

## Finding

A live QEMU trace showed displayd receiving the output update but logging
`Kanshi profile unchanged; skipping write`. The Wayland snapshot carried the
authoritative `current_mode=1024x768`, while the per-mode flags still marked
`1280x800` as current. The profile therefore remained stale.

## Candidate branch

The personal-fork branch
[`rahul/worker/displayd-mode-dirty-20260812`](https://github.com/Rahul-2k4/regolith-displayd/tree/rahul/worker/displayd-mode-dirty-20260812)
adds a regression for a mode-only change and makes Wayland snapshot conversion
honour the authoritative current mode. No upstream PR or merge was made.

Commit: [`8fa2832`](https://github.com/Rahul-2k4/regolith-displayd/commit/8fa28320eabc6462848edc08937bc2062f7df1dd)

## Verification

- focused regression passed;
- `cargo fmt --check` passed;
- `cargo test --locked --lib`: 49 passed;
- `cargo test --locked --bin regolith-displayd`: 25 passed;
- `git diff --check` passed;
- `dpkg-buildpackage -b -us -uc` passed for the unsigned amd64 package.

The existing `num_derive` warning remains.

## Bounded QEMU runtime

The unsigned package was extracted and its candidate binary was run as the
test user with the live compositor environment. The live output changed from
`1280x800 @ 74.994 Hz` to `1024x768 @ 60.004 Hz`, and the candidate rewrote the
saved `Virtual-1` profile to `1024x768@60.004Hz`. The original mode was then
restored and the packaged service restarted.

This is candidate-binary QEMU evidence. It does not prove system-wide `.deb`
installation, cold-reboot persistence, physical hardware behaviour, or mentor
acceptance. The guest package-install path remains open.
