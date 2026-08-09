# regolith-inputd Voulage package proof

Date: 2026-08-10

The tested inputd candidate is available from the personal fork at commit
[`cd1c2cd`](https://github.com/Rahul-2k4/regolith-inputd/tree/codex/inputd-touchpad-deterministic-coverage-20260810).
It guards empty Sway keyboard-layout metadata and passes 46 all-feature tests.

The isolated Voulage model candidate is
[`5d8a904`](https://github.com/Rahul-2k4/voulage/commit/5d8a9046d6eef7b4fdfcf5b5e1a14cdbac312f98).
It pins the source commit in `stage/unstable/package-model.json` for the
Ubuntu Resolute amd64 target.

## Build

Voulage cloned the public source, checked out the exact commit, generated the
quilt version `0.4.1-1-1regolith-resolute`, and built the source and binary
packages through the Debian extension.

The resulting unsigned package is available here:

[regolith-inputd_0.4.1-1-1regolith-resolute_amd64.deb](../artifacts/regolith-inputd_0.4.1-1-1regolith-resolute_amd64.deb)

SHA-256:

```text
ab4283c0b667104ceb231719ecb51ee8113edc09b5e2de2cda50ac210b48815d
```

Package metadata:

```text
Package: regolith-inputd
Version: 0.4.1-1-1regolith-resolute
Architecture: amd64
```

Lintian completed with two non-fatal warnings:

```text
regolith-inputd-dbgsym: debug-file-with-no-debug-symbols
regolith-inputd: no-manual-page
```

This proves source resolution, model resolution, and package generation. The
candidate has not been installed in QEMU, tested on physical hardware, signed,
or published to a canonical Regolith archive. The frozen installed tuple still
uses inputd source `e32d049`.
