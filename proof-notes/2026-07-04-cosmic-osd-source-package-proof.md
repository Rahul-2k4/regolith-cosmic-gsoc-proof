# cosmic-osd source package proof - 2026-07-04

Status: `Source package proof passed / binary package still pending`

## Claim

`cosmic-osd` packaging metadata has been normalized far enough for Debian quilt source package generation.

This does not yet prove a binary `.deb` build. It closes the previous source-package metadata blocker and moves the remaining blocker to binary build dependency/install path.

## Branch

- repo: `cosmic-epoch/cosmic-osd`
- branch: `rahul/week6-cosmic-osd-package-preflight`
- commit: `b816838` (`Normalize cosmic-osd source package metadata`)

## Changes

Files changed:

- `debian/changelog`
- `debian/source/format`
- `debian/source/include-binaries`
- `debian/source/options`

Summary:

- Switched source format from `3.0 (native)` to `3.0 (quilt)`.
- Set version/distribution to `0.1.0-1-1regolith-resolute` / `resolute`.
- Added `vendor.tar` to `debian/source/include-binaries`.
- Added source options to ignore generated/source-control-only paths during quilt source generation.

## Verification

Command run on `regolith-test-host`:

```bash
cd <remote-regolith-workspace>/cosmic-epoch/cosmic-osd
dpkg-buildpackage -S -us -uc -d
```

Result:

```text
dpkg-buildpackage: info: source-only upload (original source is included)
EXIT_STATUS=0
```

Artifacts produced on `regolith-test-host`:

```text
cosmic-osd_0.1.0-1-1regolith-resolute.debian.tar.xz
cosmic-osd_0.1.0-1-1regolith-resolute.dsc
cosmic-osd_0.1.0-1-1regolith-resolute_source.buildinfo
cosmic-osd_0.1.0-1-1regolith-resolute_source.changes
cosmic-osd_0.1.0-1-1regolith.orig.tar.gz
```

Small proof artifacts and full source build log are saved under:

```text
05_Testing_Proof/assets/cosmic-osd-source-package-2026-07-04/
```

The 90 MB `.debian.tar.xz` artifact was left on the laptop and listed in the asset manifest instead of copied into the vault.

## Earlier blockers resolved

The source proof exposed and resolved these packaging metadata issues:

- `3.0 (native)` source format was wrong for the Regolith quilt package flow.
- The quilt source build needed an orig tarball named for the parsed upstream version.
- Generated `vendor.tar` needed `debian/source/include-binaries`.
- `.cargo/config.toml` and `.github` needed source options because the copied orig tar did not carry those generated/local tree differences.

## Remaining blocker

Binary `.deb` proof is still pending.

Known dependency blocker from the first package check:

```text
Unmet build dependencies: cosmic-randr libpipewire-0.3-dev
```

Next step:

- Make the local build environment see the existing `cosmic-randr` artifact.
- Install or expose `libpipewire-0.3-dev`.
- Then run binary package build or Voulage local-build for `cosmic-osd`.
