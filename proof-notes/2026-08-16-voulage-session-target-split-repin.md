# Voulage target-split session repin

Date: 2026-08-16

The isolated Voulage branch
[`rahul/cosmic-exact-tuple-local-build-20260811`](https://github.com/Rahul-2k4/voulage/tree/rahul/cosmic-exact-tuple-local-build-20260811)
now pins `regolith-session` to the proven target-split commit
`831596f8f054a6904b0846b6a899912c6c13d465`.

- Voulage commit: [`5b11b055`](https://github.com/Rahul-2k4/voulage/commit/5b11b055)
- JSON parsing, focused source-pin assertion, and `git diff --check`: passed
- Changed only the unstable package model and its source-pin test

This is reproducibility evidence, not a new package build, installation, or
QEMU runtime result. Criterion 9 remains `Partial` until the exact model is
built and the complete dependency audit is rerun. The remaining
`gnome-keyring` and `gnome-themes-extra*` packages remain documented as
intentional current dependencies; they were not removed without replacement
proof.
