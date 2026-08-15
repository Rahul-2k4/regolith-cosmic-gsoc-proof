# Voulage target-split session package build

Date: 2026-08-16
Model pin: `regolith-session` `831596f8f054a6904b0846b6a899912c6c13d465`
Voulage model commit: [`5b11b055`](https://github.com/Rahul-2k4/voulage/commit/5b11b055)

The exact pinned model built successfully through the Ubuntu Resolute Voulage
local-build path on the Linux laptop.

- `regolith-session-cosmic`: `38016733cffef1d7940cccf1c0ea2bf16efffc55ca6f86f349c0d51d6623447e`
- `regolith-session-gnome-targets`: `8c1bd121aaa6c46df7c04d34956255a8a452eb20ea945a32b7f73f3458dda67`
- `regolith-session-sway`: `67deaa385fba0e7ecf333a58c25c6a44ef00332f606304b8b91133d31a48ffe2`

Package ownership inspection and the source-pin, session-package-audit, and
systemd-target tests passed. Lintian warnings were recorded for missing manual
pages, long package names, and a virtual dependency; no zero-warning claim is
made.

This is package/model evidence only. The full external dependency graph and a
fresh runtime install were not rerun from this build, so criterion 9 remains
`Partial`.
