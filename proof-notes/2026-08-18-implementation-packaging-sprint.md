# 2026-08-18 implementation and packaging sprint

This note records the accepted source and package state used by the final
work-product update. It does not promote source-only work to runtime proof.

## Accepted source commits

| Component | Personal-fork branch | Accepted source commit | Result |
|---|---|---|---|
| `regolith-session` | `codex/session-target-ownership-20260818` | `8cfc501` | COSMIC helper activation is idempotent; GNOME/COSMIC target ownership remains separate |
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
| `regolith-session` | `42dbf87` | `regolith-session-cosmic_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb`; build and eight shell tests passed; Lintian: 1 error, 8 warnings | tuple preflight verified prefix `de3df8bb...`; full hash retained in the Voulage worktree |
| `regolith-inputd` | `707eaf9` | `0.4.1-2-1regolith-resolute`; checks and Lintian returned 0 | `2d27eb6e58951ed6fdd19e0a78cbc38bed5272e37388f21ebb86ef4c46f4aaa0` |
| COSMolith | `71b5af7` | `cosmolith_0.1.0-1-1regolith-resolute_amd64.deb`; `dpkg-deb` and Lintian returned 0 | `ad5af5edee6d278c4b9990c02f13ea3b715e260686cc6b58f2f5c48f6e6bb04e` |
| `cosmic-settings` | `f6c054a` | `cosmic-settings_1.0.12-1-1regolith-resolute_amd64.deb`; build and metadata/content passed; Lintian returned 2 | `5459b91e7d5281ff0727cef8431a31a7e1dc4a70031da855984938068563d29f` |

The session artifact's full binary hash is not present in the local tracker
text; the current tuple preflight records the verified prefix above and the
full hash remains in the Voulage worktree. The COSMIC settings Lintian result
includes two errors and existing warnings. No zero-warning claim is made.

The reviewed displayd source `ba8a35a` had no source-level findings, but its
Voulage repin/build was still pending at this checkpoint. No displayd package
artifact is attributed to `ba8a35a` here.

## Rejected inputd correction

Inputd commit `531f3b9` is rejected and must not be packaged or merged. Its
reverse-sync implementation collapses a comma-separated COSMIC layout list to
one entry, so a value such as `us,ara` can lose `us` on the next apply/watch
cycle. The accepted package source remains `10ba5d8` until a non-destructive
active-layout representation is implemented and reviewed.

## GNOME-free package boundary

Source/package inspection confirmed that `regolith-session-cosmic` has no
GNOME runtime dependencies. GNOME dependencies remain isolated to the
Flashback/Sway packages. This is a package dependency result, not a claim that
the complete installed system has no GNOME-related transitive packages.

## Runtime boundary and headline

The exact four-package tuple was staged and hash-verified, but the combined
QEMU run stopped before overlay creation because the runtime-only `GUEST_PASS`
variable was unset. No password was stored or guessed, no guest was modified,
and no new runtime claim follows from this preflight.

The strict work-product headline therefore remains **5/12 criteria fully met,
62-68% overall, QEMU-only** until the tuple runs. Hardware, native COSMIC
settings behavior, archive publication, and maintainer acceptance remain open.
