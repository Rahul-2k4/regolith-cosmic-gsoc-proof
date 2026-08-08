# Current branch-ref Voulage tuple - 2026-08-08

This proof records the repinned Voulage COSMIC package model and four
successful Resolute package builds. It does not claim release readiness.

## Source refs

| Component | Branch | Verified SHA |
|---|---|---|
| Voulage package model | `codex/voulage-model-repin-regolith-cosmic-20260808` | `53c342c2492524210b4856f581e1abfc6e904a7c` |

Package-model SHA: `e0ee1b8d7696185ab9741b9b87d561771e5b6e10a956fceb93dd8837a45ccfcb`.

## Build results

All four builds returned exit `0`. Builds ran sequentially with one isolated
build root per package. The build environment used Linux Bash 5.2, an apt-only
no-sudo test shim, and displayd's absolute nightly Rust/Cargo toolchain. No
source or lock files were edited.

| Package | SHA-256 |
|---|---|
| `regolith-session-cosmic_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb` | `332146a823b5041545284a5b99d995d402c9fb74437721eb513088d13ecba141` |
| `regolith-wm-config_4.11.11-1regolith-resolute_amd64.deb` | `df9e249dfac3f89b3768d77030d5be20fa2fa711af800d956e73f2a591db4244` |
| `regolith-inputd_0.4.1-1-1regolith-resolute_amd64.deb` | `69a74a564b157b07ceb66701af0e4c7749c2717c9cc79ca09745b49d54d6e777` |
| `regolith-displayd_0.3.4-1regolith-resolute_amd64.deb` | `c9c331faa889c32a160caed08386e70ef45c83273d8fe0c8e155b2185122c8a8` |

## QEMU staging tuple

The following separate table records the seven binary packages staged for
QEMU installation. It is staging evidence only and is not build provenance.

| Staged package | SHA-256 |
|---|---|
| `regolith-session-cosmic_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb` | `332146a823b5041545284a5b99d995d402c9fb74437721eb513088d13ecba141` |
| `regolith-sway-root-config_4.11.11-1regolith-resolute_amd64.deb` | `1776e42639dd39cddd8a535e29fd5c7ba97285e97eec7f6130d381b871f45270` |
| `regolith-sway-ilia_4.11.11-1regolith-resolute_amd64.deb` | `cbbb5091138cb58263ffbdc830fe283500ff299ba05062753e00b5d7109d05db` |
| `regolith-sway-default-style_4.11.11-1regolith-resolute_amd64.deb` | `976c559d6c7fa00685ffe041dfe5fe96b23943e3c6541046c495718794e30775` |
| `regolith-sway-cosmic-idle_4.11.11-1regolith-resolute_amd64.deb` | `184e824af699560ecda025b33a626cf433b1e0337e6199000c92282d2dc953b2` |
| `regolith-inputd_0.4.1-1-1regolith-resolute_amd64.deb` | `69a74a564b157b07ceb66701af0e4c7749c2717c9cc79ca09745b49d54d6e777` |
| `regolith-displayd_0.3.4-1regolith-resolute_amd64.deb` | `c9c331faa889c32a160caed08386e70ef45c83273d8fe0c8e155b2185122c8a8` |

Builds used `-us -uc`, so packages are unsigned. Known lintian metadata and
manual-page findings remain; lintian is not presented as clean.

## QEMU boundary

The seven COSMIC-relevant binary packages are the exact staging tuple for
disposable QEMU. Installation and a visible greeter-selected COSMIC login
remain pending. Do not interpret staged files as runtime proof.

Remaining acceptance work includes exact-tuple installation, target/helper
checks, GNOME coexistence, rollback, signing/lintian disposition, native idle
lifecycle, and hardware validation. The Settings resolution selector remains
blocked in QEMU by a Wayland popup-renderer crash before `cosmic-randr`.
