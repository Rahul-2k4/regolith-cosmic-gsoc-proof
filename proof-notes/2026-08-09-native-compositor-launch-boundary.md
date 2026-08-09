# Native compositor launch boundary - 2026-08-09

The QEMU guest has the native `cosmic-comp` package and the standard COSMIC
session entry. The experimental Regolith entry is a separate path that runs
`cosmic-session` with the Regolith runtime wrapper and Sway.

A direct SSH launch of `cosmic-comp` failed with `Backend initialized without
output`. That is an invalid non-seat diagnostic, not native graphical proof.
No SSH-side compositor launch is counted as success.

The valid test is the real `cosmic-greeter` flow: select `COSMIC` from the
standard COSMIC session entry, log in at the QEMU console, and verify a
user-owned `cosmic-session` and `cosmic-comp`, no Sway process, output state,
and healthy session services. Until that console selection is completed,
native compositor/session runtime remains open.
