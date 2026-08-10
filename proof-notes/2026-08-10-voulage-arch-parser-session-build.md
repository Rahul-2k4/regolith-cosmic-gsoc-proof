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

This exact artifact has not yet been installed in QEMU. It is build and
packaging evidence only. Signing, publication, and final release review remain
open.
