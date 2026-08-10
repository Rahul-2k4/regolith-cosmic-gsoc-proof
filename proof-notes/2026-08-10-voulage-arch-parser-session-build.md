# Voulage `--arch` parser fix and session build

Date: 2026-08-10

The local Voulage builder documented `--arch` but rejected it before starting a
build. The isolated fix is on [commit `a8b0e0d`](https://github.com/Rahul-2k4/voulage/commit/a8b0e0df588036bddba021b2de930fb5b73bed33).
The focused parser test, shell syntax check, `git diff --check`, and the
canonical session source-pin check passed.

The fixed builder produced this Ubuntu Resolute amd64 package from session
source `3523047b7c2f7a2ca4e3d1fd800c10c342ca7a19`:

```text
Package: regolith-session-cosmic
Version: 1.2.0-1ubuntu1-1regolith-resolute
SHA-256: a6cc9e69276ba4d5c76d53885036e79cc3a547255e6de59c1bfe6936a45eb6ca
```

The package contains the COSMIC launcher, `regolith-cosmic.target`, and the
`regolith-cosmic.desktop` Wayland session entry. Source-only Lintian returned
no findings. The standalone COSMIC binary has one missing-manual-page warning;
the complete session changeset still contains unrelated sibling-package
findings, so this is not a release-clean claim.

The exact archive was installed in the disposable QEMU guest. After a reboot,
a fresh greetd login reported the expected package version, clean `dpkg --audit`
and `dpkg -V`, an active COSMIC target with healthy inputd and displayd, and
`Result=success` with `NRestarts=0` for both helpers. `cosmic-session`, Sway,
`regolith-inputd`, and `regolith-displayd` were running.

The matched baseline archive was then restored. Its SHA-256 was
`8dd21a40e1d8cb28ff36edd4bf41c0c82fe4ce0e8cfd09b8a9743128d2065877`, and the
same package, target, helper, and process checks passed after rollback.

This closes the builder, artifact, QEMU cold-login, and rollback checks. It
does not prove native `cosmic-comp` display mutation, physical hardware
behavior, signing, publication, or final mentor acceptance.
