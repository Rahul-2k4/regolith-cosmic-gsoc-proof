# Displayd candidate persistence: storage pass, apply failure

Date: 2026-08-16
Candidate source: [`e606e0c`](https://github.com/Rahul-2k4/regolith-displayd/commit/e606e0c)
Candidate package SHA-256: `c4e88d4d3d1f484da4ee45cb8820dd83066aa356cb99e49b9bc1ac5dc499bbd0`

The candidate was installed into a fresh disposable QEMU overlay with offline
guest customization. `Virtual-1` changed live from `1280x800@74.994Hz` to
`1024x768@60.004Hz`; the human-readable profile recorded the new mode. After
a QEMU reset and fresh COSMIC/Sway login, the profile still contained
`1024x768@60.004Hz`.

The post-reset Sway output remained at `1280x800@74.994Hz`. The displayd and
inputd services were active with successful results and zero restarts; Kanshi
was inactive under the current COSMIC target contract.

This is a **storage pass but apply failure**, not full display-persistence
proof. Criterion 7 remains `Partial`. The remaining design choice is a direct
Wayland output-management apply path in displayd versus a separate COSMIC
target helper. No Sway-only fallback was added.
