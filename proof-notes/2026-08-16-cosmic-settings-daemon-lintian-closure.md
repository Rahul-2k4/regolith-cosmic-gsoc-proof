# `cosmic-settings-daemon` Voulage metadata closure

Date: 2026-08-16
Status: unsigned personal-fork build; package-quality evidence

## Source

- Repository: https://github.com/Rahul-2k4/cosmic-settings-daemon
- Branch: [`codex/cosmic-settings-daemon-lintian-20260816`](https://github.com/Rahul-2k4/cosmic-settings-daemon/tree/codex/cosmic-settings-daemon-lintian-20260816)
- Metadata correction commit: [`59d674e1`](https://github.com/Rahul-2k4/cosmic-settings-daemon/commit/59d674e1dd2aa98bf3a6a481718ea1df9daf6790)

## Build result

The exact branch was built through the local Voulage Debian extension for
Ubuntu Resolute. Cargo dependencies were vendored and the optimized Rust
binary compiled successfully.

- Package: `cosmic-settings-daemon`
- Version: `0.1.0-1-1regolith-resolute`
- Architecture: `amd64`
- SHA-256:
  `e10c88b9a3f71b9327b4a165dca8c87f343cc3756a00d269e5cc90d6386aec3d`
- `dpkg-deb` metadata and package description are valid.
- Direct Lintian on the binary `.deb` exited `0` with no package tags.

## Bounded residuals

The Voulage source changes-file run still reports these warnings:

- `build-depends-on-obsolete-package` for `pkg-config`.
- `odd-historical-debian-changelog-version` for the inherited `0.1.0`
  changelog entry.
- The generated dbgsym changes-file reports
  `debug-file-with-no-debug-symbols`.

These are recorded, not suppressed. This artifact proves vendored compilation,
correct Resolute version composition, and binary-package metadata quality. It
does not prove signing, official publication, or graphical runtime.

## Reproduction shape

Use the Voulage `local-build.sh` Debian extension with the public repository,
the branch above, package name `cosmic-settings-daemon`, distro `ubuntu`,
codename `resolute`, stage `unstable`, and the documented local-build option
that skips host dependency installation when dependencies are already present.
