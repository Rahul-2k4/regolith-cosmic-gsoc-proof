# COSMIC session launcher manpage Voulage proof

Date: 2026-08-10

## Scope

The reviewed `regolith-session` candidate `bdb2b0097ef45a2ff572503832ef8a41b9d230e4` adds only the `regolith-session-cosmic-launch(1)` manual page, its Debian install entry, and a packaging assertion. It does not change session runtime logic.

## Build

The candidate was rebuilt through Voulage commit `db0ff7bca46e10fb69a57cbd795bea23a73c1a82`. The isolated model changed only the `regolith-session` source ref from `3523047b7c2f7a2ca4e3d1fd800c10c342ca7a19` to the candidate commit. The build used the mentor-approved quilt/Regolith version format:

```text
regolith-session-cosmic_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb
SHA-256: cd3676cf4484cd1129511a32f7f3ad5ad8cfba9da6b7fbdb4e73f10c43e89c85
```

Voulage returned build status `0`, the systemd-target test passed, and the exact COSMIC package metadata was:

```text
Package: regolith-session-cosmic
Version: 1.2.0-1ubuntu1-1regolith-resolute
Architecture: amd64
```

## Verification

- `dpkg-deb -c` contains `usr/share/man/man1/regolith-session-cosmic-launch.1.gz`.
- Standalone `lintian` on the exact COSMIC package returned no findings.
- The candidate worktree passed `git diff --check` and `tests/regolith-cosmic-launch.sh`.

## QEMU install and rollback

The exact candidate package was installed in the disposable qualification QEMU guest. The guest reported the expected package/version, the launcher manpage was present, `dpkg --audit` was empty, and `regolith-cosmic.target`, `regolith-init-inputd.service`, and `regolith-init-displayd.service` were active. The retained baseline package was then reinstalled with a forced downgrade and the same target/helper health plus empty `dpkg --audit` were verified.

The full source build still reports unrelated legacy findings on sibling packages (`regolith-session-common`, `regolith-session-sway`, and flashback packages). This note claims only the exact COSMIC binary result; it does not claim the complete source package is lintian-clean, signed, or published canonically. The QEMU result is package/target health proof, not new functional session behavior because the change is documentation-only.
