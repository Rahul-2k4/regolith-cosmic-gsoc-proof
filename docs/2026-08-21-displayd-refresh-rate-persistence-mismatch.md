# displayd persists the wrong refresh rate — disclosed, not fixed this session

Date: 2026-08-21
Status: Open, disclosed. Not scheduled before the Aug 24 deadline.

## What happens

Requesting `apply-persistent` with mode `1920x1080@60Hz` results in
`1920x1080@50Hz` being applied and surviving reboot. `60Hz` is present in the
output's advertised mode list and marked `is-current: false` at the time of
the call, so it isn't unavailable — it simply wasn't the one selected.
Resolution and scale both persist exactly as requested; only the refresh
rate is wrong.

## Likely cause (not yet confirmed by reading the source)

Mode-matching in the apply path probably keys on resolution alone and picks
whichever mode entry is first/default for that resolution, ignoring the
requested refresh rate. Would need a source read of
`regolith-displayd`'s mode-selection logic (`wayland_observer.rs` or
wherever `ApplyMonitorsConfig`'s mode argument is resolved against the
output's `Mode` list) to confirm and fix properly.

## Why it's not being fixed this week

Found on 2026-08-21, three days before the Aug 24 deadline, via
`05_Testing_Proof/2026-08-21-displayd-real-apply-and-persistence-qemu.md`.
Fixing it properly needs a source read, a TDD regression test, a rebuild,
and a fresh QEMU reboot-persistence proof — the same cycle as the three
bugs already fixed this session, each of which took the better part of a
day. Disclosing it honestly costs nothing; rushing a fix this late risks
breaking the two things that do already work (resolution and scale
persistence), with no time left to catch a regression.

## Disposition

Recorded as a known, scoped limitation. Not promoted, not hidden. If time
remains after Lane A/B/C close, this is the next candidate — otherwise it's
inherited as a follow-up item, same as the archive-signing and upstream-PR
items in the honest ceiling.
EOF
echo done