# regolith-inputd Voulage package proof

Date: 2026-08-10

The tested inputd candidate is available from the personal fork at commit
[`cd1c2cd`](https://github.com/Rahul-2k4/regolith-inputd/tree/codex/inputd-touchpad-deterministic-coverage-20260810).
It guards empty Sway keyboard-layout metadata and passes 46 all-feature tests.

The isolated Voulage model candidate is
[`4dc7de8`](https://github.com/Rahul-2k4/voulage/commit/4dc7de80c8dfb0b23226a67f48f2e343725ceeb3).
It pins the packaging-remediation source commit in
`stage/unstable/package-model.json` for the Ubuntu Resolute amd64 target.

The inputd packaging branch is
[`b380c9a`](https://github.com/Rahul-2k4/regolith-inputd/commit/b380c9aa8f75b8d2da657b58b459a861c3a5d56b).
It adds a manual page and preserves DWARF data for the debug-symbol package.

## Build

Voulage cloned the public source, checked out the exact commit, generated the
quilt version `0.4.1-2-1regolith-resolute`, and built the source and binary
packages through the Debian extension.

The resulting unsigned package is available here:

[regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb](../artifacts/regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb)

SHA-256:

```text
759f87dc908182359a17d3930bf67b0f4c3a188fe02e75bdc71f7bd9238ff193
```

Package metadata:

```text
Package: regolith-inputd
Version: 0.4.1-2-1regolith-resolute
Architecture: amd64
```

Direct Debian Lintian on the packaging-remediation build was clean for the
binary and debug package. The Voulage wrapper build itself retained one
warning because its generated entry and the source entry have the same calendar
date:

```text
regolith-inputd: latest-changelog-entry-without-new-date
```

The package contains `regolith-inputd(8)` and the debug-symbol package contains
DWARF data. This proves source resolution, model resolution, package
generation, and the packaging cleanup. The candidate has not been installed in
QEMU, tested on physical hardware, signed, or published to a canonical Regolith
archive. The frozen installed tuple still uses inputd source `e32d049`.
