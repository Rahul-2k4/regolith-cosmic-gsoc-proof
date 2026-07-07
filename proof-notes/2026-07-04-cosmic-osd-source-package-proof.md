# cosmic-osd source package proof - 2026-07-04

Status: `Source package proof passed / binary package still pending`

## Claim

`cosmic-osd` packaging metadata has been normalized far enough for Debian quilt source package generation.

This does not yet prove a binary `.deb` build. It closes the previous source-package metadata blocker and moves the remaining blocker to binary build dependency/install path.

## Branch

- repo: `cosmic-epoch/cosmic-osd`
- branch: `rahul/week6-cosmic-osd-package-preflight`
- current public branch commit: `3a50b75` (`Ignore target artifacts in source package diff`)
- original proof commit before upstream rebase: `b816838`

Rebase note:

- On 2026-07-08, this branch was rebased onto current `pop-os/cosmic-osd` `origin/master`.
- After rebase, the first full source-package rerun exposed generated `target/` artifacts in the `dpkg-source` diff phase.
- Fixed by adding `target/.*` to `debian/source/options` `extend-diff-ignore`.
- Fresh full rerun now passes with `dpkg-buildpackage -S -us -uc -d`.

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

Command run on the packaging test host:

```bash
cd <remote-regolith-workspace>/cosmic-epoch/cosmic-osd
dpkg-buildpackage -S -us -uc -d
```

Result:

```text
dpkg-buildpackage: info: source-only upload (original source is included)
EXIT_STATUS=0
```

Fresh rerun after upstream rebase:

```text
dpkg-buildpackage: info: source-only upload (original source is included)
EXIT_STATUS=0
```

Artifacts produced on the packaging test host:

```text
cosmic-osd_0.1.0-1-1regolith-resolute.debian.tar.xz
cosmic-osd_0.1.0-1-1regolith-resolute.dsc
cosmic-osd_0.1.0-1-1regolith-resolute_source.buildinfo
cosmic-osd_0.1.0-1-1regolith-resolute_source.changes
cosmic-osd_0.1.0-1-1regolith.orig.tar.gz
```

Small proof artifacts and the full source build log are retained in the private working vault. This public note includes the command, exit status, artifact names, and blocker summary.

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
