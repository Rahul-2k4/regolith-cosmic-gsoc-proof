# Current branch-ref Voulage tuple - 2026-08-08

This proof records the current COSMIC source-of-truth branches and four
successful Resolute package builds. It does not claim release readiness.

## Source refs

| Component | Branch | Verified SHA |
|---|---|---|
| `regolith-session` | `rahul/cosmic-idle-owner-canonical-20260808` | `cbb4e4c59d341865fe7644e41c1a22f8147c8808` |
| `regolith-wm-config` | `rahul/cosmic-idle-owner-wm-config-20260808` | `865243a7a8f0a9c3fb52653f2db3884c82021565` |
| `regolith-inputd` | `rahul/inputd-handler-startup-retry-fixed-20260802` | `e612e20bba09d9d0a722c141b1df2be513c5abf6` |
| `regolith-displayd` | `rahul/cosmic-systemd-displayd-metadata` | `fa8655c4e95b5af97970dd49cab31d2dce3ed4cb` |

Voulage package proof was built at model commit
`41200693d69b14914f4ff15ea55c674e80b1a953`. The named public branch later
advanced to `997a7e26eaf1a74ad3ba81c89a3859f457812590`; the published package
hashes must not be rebuilt from that moving tip without a fresh tuple audit.
The current tip changes the Resolute `regolith-displayd` entry to `6c94fd...`,
so it is not equivalent to the tested `fa8655c...` tuple.

## Build results

All four builds returned exit `0`. Builds ran sequentially with one isolated
build root per package and `SKIP_APT_BUILD_DEP=true`.

| Package | SHA-256 |
|---|---|
| `regolith-session-cosmic_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb` | `bdd8dd763c28145b6439fda592b35813429a20b96af4ce6dd2e1bec9e5d2c095` |
| `regolith-wm-config_4.11.11-1-1regolith-resolute_amd64.deb` | `9d115240e351f895308b72907e1ef02c49f0c7050d25008ec424ad6b71f7f09f` |
| `regolith-inputd_0.4.1-1-1regolith-resolute_amd64.deb` | `16506d0d0ade08ed566a7b04db093cfc508add9e626f1b735f5d190d744c8535` |
| `regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb` | `0444483c883bff81cbfe16793ca32afbddd8442f9978fab32e7ed31c680668cd` |

## QEMU staging tuple

The following separate table records the seven binary packages staged for
QEMU installation. It is staging evidence only and is not build provenance.

| Staged package | SHA-256 |
|---|---|
| `regolith-session-cosmic_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb` | `bdd8dd763c28145b6439fda592b35813429a20b96af4ce6dd2e1bec9e5d2c095` |
| `regolith-sway-root-config_4.11.11-1-1regolith-resolute_amd64.deb` | `b6f79493deac28d50795b7e2e5f7b9804f5e4f786111890fb9aac602013a3e12` |
| `regolith-sway-ilia_4.11.11-1-1regolith-resolute_amd64.deb` | `4220b4edbbd69910563b758b4f9cc6e13613aa88efbf066e2189aa3e1348a433` |
| `regolith-sway-default-style_4.11.11-1-1regolith-resolute_amd64.deb` | `69cf8ef1a5c525ecab6665ce3180d455e3c420ca3b74a266bbfddf63b0b893a3` |
| `regolith-sway-cosmic-idle_4.11.11-1-1regolith-resolute_amd64.deb` | `a322a48b802f47a221588c542155469da3d348ae373e02c4c68547231d7494a5` |
| `regolith-inputd_0.4.1-1-1regolith-resolute_amd64.deb` | `16506d0d0ade08ed566a7b04db093cfc508add9e626f1b735f5d190d744c8535` |
| `regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb` | `0444483c883bff81cbfe16793ca32afbddd8442f9978fab32e7ed31c680668cd` |

Builds used `-us -uc`, so packages are unsigned. Lintian completed; existing
metadata/manual-page findings remain recorded for inputd and displayd.

## QEMU boundary

The seven COSMIC-relevant binary packages were staged in disposable QEMU and
their SHA-256 values matched the build list. Installation and a visible
greeter-selected COSMIC login still require a manual guest action. Do not
interpret staged files as runtime proof.

Remaining acceptance work includes exact-tuple installation, target/helper
checks, GNOME coexistence, rollback, signing/lintian disposition, native idle
lifecycle, and hardware validation. The Settings resolution selector remains
blocked in QEMU by a Wayland popup-renderer crash before `cosmic-randr`.
