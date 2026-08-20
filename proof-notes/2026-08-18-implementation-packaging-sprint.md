# 2026-08-18 implementation and packaging sprint

This note records the accepted source and package state used by the final
work-product update. It does not promote source-only work to runtime proof.

## Accepted source commits

| Component | Personal-fork branch | Accepted source commit | Result |
|---|---|---|---|
| `regolith-session` | `rahul/cosmic-idle-target-start-20260818` | `54d5684` | COSMIC helper activation is idempotent; native COSMIC idle is gated on native compositor ownership; GNOME/COSMIC target ownership remains separate |
| `regolith-inputd` | `codex/inputd-cosmic-backend-20260818` | `10ba5d8` | one backend per package; GNOME remains default and COSMIC uses `CARGO_FEATURES=cosmic` |
| COSMolith | `codex/cosmolith-input-layout-variant-20260818` | `592c1f6` | initial layout state, variant-only changes, and comma-separated multi-layout changes covered |
| `cosmic-settings` | `codex/cosmic-settings-regolith-filter-20260818` | `e530ab7` | exact Regolith COSMIC token filters compositor-only pages |
| `regolith-displayd` | `codex/displayd-logical-monitor-identity-20260818` | `ba8a35a` | connector identity is used consistently for `LogicalMonitor` equality and hashing |

All listed source branches were pushed to Rahul's personal forks only. No
upstream publication or merge is claimed.

## Voulage artifacts

The accepted package builds below are unsigned Ubuntu Resolute amd64 artifacts.
They are package/build evidence, not archive publication or runtime evidence.

| Package | Voulage model commit | Artifact and result | SHA-256 |
|---|---|---|---|
| `regolith-session` | `6ae27b2` | `regolith-session-cosmic_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb`; target/idle tests, metadata, and package checks passed; direct COSMIC Lintian: 0 | `8e3559e8dfd1eb33cbe3187da4772055a4f0ee048d69bf188ca0196b43635643` |
| `regolith-inputd` | `707eaf9` | `0.4.1-2-1regolith-resolute`; checks and Lintian returned 0 | `2d27eb6e58951ed6fdd19e0a78cbc38bed5272e37388f21ebb86ef4c46f4aaa0` |
| COSMolith | `71b5af7` | `cosmolith_0.1.0-1-1regolith-resolute_amd64.deb`; `dpkg-deb` and Lintian returned 0 | `ad5af5edee6d278c4b9990c02f13ea3b715e260686cc6b58f2f5c48f6e6bb04e` |
| `cosmic-settings` | `f6c054a` | `cosmic-settings_1.0.12-1-1regolith-resolute_amd64.deb`; build and metadata/content passed; Lintian returned 2 | `5459b91e7d5281ff0727cef8431a31a7e1dc4a70031da855984938068563d29f` |
| `regolith-displayd` | `79de7831` | `regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb`; `dpkg-deb` metadata/content passed; Lintian: 1 error, 4 warnings | `11f0b101c02319b94664b6afb6e82325d3caaba137ea53768471e0a443056815` |

The later clean inputd source follow-up is `3b3309a`, based directly on
`10ba5d8` and excluding the rejected reverse-sync commit. Its Voulage model is
`1f37ab8d`; the rebuilt package is
`regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb` with SHA-256
`5f2a280600b1a8a6ad01f6d5275b0d772d272a2e316b4439532c9b96e036b33b`.
COSMIC tests, vendored build, package metadata/content, and direct Lintian
passed. The final tuple runbook uses this clean artifact.

The OSD source fix `44eacc8` keeps sink/source active indices correct when
nodes are removed. Its focused/full tests, formatting, check, and diff checks
passed. Voulage model `272dbc0` built
`cosmic-osd_0.1.0-1-1regolith-resolute_amd64.deb`, SHA-256
`0463b0526de5801baa96583741ff291c5fe97f8a4c5e0b9faa14ef719011cfc6`.
Vendored offline build and package metadata/content checks passed; direct
Lintian reported four metadata/documentation issues. This does not change
runtime claims.

The session artifact's full binary hash is not present in the local tracker
text; the current tuple preflight records the verified prefix above and the
full hash remains in the Voulage worktree. The COSMIC settings Lintian result
includes two errors and existing warnings. No zero-warning claim is made.

The displayd package is built from the reviewed source `ba8a35a` through model
`79de7831`. It is an unsigned package/build result, not archive publication or
runtime proof.

## Rejected inputd correction

Inputd commit `531f3b9` is rejected and must not be packaged or merged. Its
reverse-sync implementation collapses a comma-separated COSMIC layout list to
one entry, so a value such as `us,ara` can lose `us` on the next apply/watch
cycle. The clean package source is now `3b3309a`; the rejected reverse-sync
branch remains excluded.

## GNOME-free package boundary

Source/package inspection confirmed that `regolith-session-cosmic` has no
GNOME runtime dependencies. GNOME dependencies remain isolated to the
Flashback/Sway packages. This is a package dependency result, not a claim that
the complete installed system has no GNOME-related transitive packages.

## Runtime boundary and headline

The exact five-package tuple was staged and hash-verified. The corrected
runbook contract passes, and one disposable run reached guest SSH before the
supplied candidate guest credential was rejected by sudo. Cleanup removed the
overlay and QEMU process; no password was stored, and no new runtime claim
follows from this attempt.

After that preflight, an offline-prepared disposable overlay was used to set a
temporary overlay-local credential and preinstall the tuple. The normal runner
then completed the child-overlay install, reboot, greetd authentication, and
COSMIC session start with `RUNTIME_RC=0`. The detailed result is in
`2026-08-18-clean-inputd-final-tuple-qemu-runtime.md`; all temporary state was
removed afterward.

The strict work-product headline therefore remains **5/12 criteria fully met,
62-68% overall, QEMU-only** until the tuple runs. Hardware, native COSMIC
settings behavior, archive publication, and maintainer acceptance remain open.
