# Frozen `regolith-displayd` source audit

Date: 2026-08-10

The frozen displayd source is commit
`817becd9dc7e6a12f13f3f30f663555212ae78fa`. A focused comparison with the
newer `21e4553` candidate confirmed that the frozen source already contains
the COSMIC Wayland output observer and the requested hardening for logical
monitor equality/hash, fractional scale, asynchronous observation, and empty
output profiles.

Checks on the frozen source:

- `cargo fmt --check`: passed
- `cargo test --locked`: 73 tests passed
- `git diff --check`: passed
- frozen-source diff after review: empty

The newer candidate was not transplanted because it changes the runtime
contract and removes the preferred Wayland observer path. This proof closes
the source-review subgate only. Native `cosmic-comp` mutation, native
persistence, physical or equivalent hotplug, mixed-DPI coverage, and direct
Settings-panel proof remain open.
