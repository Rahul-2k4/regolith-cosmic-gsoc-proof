# `cosmic-session` Voulage vendoring gate

This note records a focused Ubuntu Resolute amd64 Voulage build for the
`cosmic-session` integration package.

| Input | Value |
|---|---|
| Source | `https://github.com/Rahul-2k4/cosmic-session.git` |
| Immutable ref | `e100aafc3f6b550057be7fdc401ff33c6f1db758` |
| Package version | `1.0.0-1-1regolith-resolute` |
| Voulage model commit | `5006cd1bfa8dabdb0763b95e1d9bae4877ae7f96` |

The run vendored `232` Rust source entries, created the Debian source package,
and ran Lintian. The source artifacts were created and hashed as follows:

```text
d98162b552e472a49e1945320af38a1bace9fe4625116064fb5d775460bb0a54  cosmic-session_1.0.0-1-1regolith-resolute.debian.tar.xz
5cadcdc148fdaa14539ea062f253b3fa3e985634339ae84850af26f8edf03d8d  cosmic-session_1.0.0-1-1regolith-resolute.dsc
f3b2a6a7bf9091516d04f66d0d3ecb2b9a0369148bedfabec3d02cdab95a14b6  cosmic-session_1.0.0-1regolith.orig.tar.gz
6c314cde0e68f17592fa06548bc741f21ad17d557aba76970ffcbe738c0077ff  cosmic-session_1.0.0-1-1regolith-resolute_source.buildinfo
4a17dd74c814d7ecac950c1cdcc4a0d421366d7bb6d07e892aa872938951d2f5  cosmic-session_1.0.0-1-1regolith-resolute_source.changes
```

Lintian reported two source warnings: an incomplete GPL-3.0-only DEP-5
paragraph and an unusual historical `1.0.0` changelog version for a
non-native package. The run stopped at signing because the builder has no
private key for `System76 <info@system76.com>` (`BUILD_RC=1`).

This is source vendoring/source-package proof only. It does not claim a
binary `.deb`, signing, archive publication, installation, or QEMU runtime
proof. The next gate is an unsigned binary build followed by the package,
systemd-target, launch/runtime, and exact QEMU replay checks.
