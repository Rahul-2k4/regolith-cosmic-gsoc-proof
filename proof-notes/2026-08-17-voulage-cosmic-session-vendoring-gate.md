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

Lintian reported one binary error, `extended-description-is-empty`, and
warnings for the synopsis and missing manual pages. The binary artifact was
still produced and published to the isolated output:

```text
cosmic-session_1.0.0-1-1regolith-resolute_amd64.deb
SHA-256: 0da40310a3993f5458827969f44105e3e7fa330af3481c6e03f671271b500c28
```

The build command therefore returned non-zero because of Lintian, not because
Rust vendoring or Debian binary creation failed. No signed archive claim is
made.

The exact artifact was installed in a disposable copy-on-write Pop!_OS QEMU
overlay. Installation returned `INSTALL_RC=0`; after reboot and greetd login,
`cosmic-session` and Sway were running, `regolith-cosmic.target` was active,
`regolith-gnome.target` was inactive, both Regolith helper services were
active, the launcher/workspace key paths worked, and `dpkg --audit` was empty.
The long `regolith-displayd` process-name check emitted the standard `pgrep`
15-character warning; the service check reported `ActiveState=active`,
`SubState=running`, and a live `MainPID`, so no separate process-name claim is
made. The harness returned `COSMIC_SESSION_QEMU_RC=0` and removed the overlay
while leaving the protected base image unchanged. This is QEMU proof only.

## Corrected metadata candidate

The first binary above is retained as the historical baseline. A minimal
Debian long-description patch was applied on the personal-fork branch
[`codex/cosmic-session-lintian-description-20260817`](https://github.com/Rahul-2k4/cosmic-session/tree/codex/cosmic-session-lintian-description-20260817)
at source commit `c103c5ed84a4f107540713862c975df34b65c1a3`. The isolated
Voulage rebuild returned `BUILD_RC=0`, and the corrected unsigned binary is:

```text
cosmic-session_1.0.0-1-1regolith-resolute_amd64.deb
SHA-256: 76d9a5fc3e910ffd2c56ce52fae99f5e3c20e1bcf5ee023f2587e5dca29774c2
```

The former `extended-description-is-empty` error is resolved. Four warnings
remain: the synopsis starts with an article, the two binaries have no manual
pages, and the generated dbgsym package has no debug symbols. No
zero-warning, signed, or archive-publication claim is made.

The corrected package was replayed through the same disposable QEMU
install/reboot/greetd harness. `INSTALL_RC=0` and
`COSMIC_SESSION_LINTIAN_FIX_QEMU_RC=0`; COSMIC target was active, GNOME target
inactive, helper services were active, launcher/workspace key paths passed,
and `dpkg --audit` was empty. The protected base image was unchanged. The
exact stdout and package are retained in the local audit directory. This is
still QEMU-only proof.

## Signed archive replay boundary

The corrected package was staged into a disposable copy of the retained
31-package Resolute signed pool. Repository metadata was regenerated and
verified in a fresh Ubuntu 26.04 container: `APT_UPDATE_RC=0`, with no
`NO_PUBKEY`, `BADSIG`, `EXPKEYSIG`, or unsigned-repository result. The pool is
incomplete for a full install, however: `APT_INSTALL_RC=100` because
`cosmic-workspaces`, `trawlcat`, `trawld`, `trawldb`, and other runtime
providers are not present. This is a dependency-pool boundary, not a signing
failure. The previous full DoD replay used the real Regolith archive as a
second signed source; a complete corrected-artifact archive replay remains
open.

The next gate is the package/archive closure. Signing, archive publication,
and maintainer acceptance remain separate.
