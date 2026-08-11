# Target-owned helper lifecycle source review

Date: 2026-08-11
Scope: isolated `regolith-inputd` and `regolith-displayd` candidates

## What changed

The two candidates add explicit stop/restart ownership for the GNOME and
COSMIC session targets while keeping the existing generic graphical-session
ownership:

- `regolith-inputd`: `f1252bbb7258f3f33692906d7a3b8f440a0a49ae`
- `regolith-displayd`: `8dfb80173613d6c74510bd3ba51aed3bfea6ff7d`

The changes add `PartOf=regolith-gnome.target` and
`PartOf=regolith-cosmic.target` to the helper units. They do not add a new
start dependency. The code-review pass found no medium or high-severity issue.
GNOME compatibility was checked at the unit-metadata level; a live GNOME
stop/restart test was not run.

## Checks

Inputd passed its exact-commit format check, COSMIC-only test suite (`47
passed`), release build, and shell syntax check. Displayd passed its exact-
commit format check, `73` locked tests, cargo check, and systemd metadata test.

The inputd systemd script still fails on both the base and candidate commits
because it expects `CARGO_PROFILE_RELEASE_DEBUG=2`, while the repository has
`export CARGO_PROFILE_RELEASE_DEBUG = 2`. That assertion mismatch predates this
change and is recorded rather than hidden.

## Packaging boundary

The exact Voulage build staged the displayd commit and reached `debuild`, then
stopped before compilation because the Debian build selected `/usr/bin/cargo
1.75.0` for a version-4 Cargo lockfile. A temporary copied-tree experiment
confirmed that a PATH override does not change that selection. It exited `25`.

No `.deb`, source package, Voulage publication, or QEMU runtime proof was
produced for these candidates. They remain unmerged. The strict project status
therefore stays at `4/12` fully met and `62-68%`.

## Package build follow-up

The proven Voulage Rust-path fix `c88d93a0` was combined with the existing
local apt-skip change `49f26e14` in disposable builder clones. Both exact
source commits then produced Resolute source and binary packages:

| Package | Version | Binary SHA-256 |
|---|---|---|
| `regolith-inputd` | `0.4.1-2-1regolith-resolute` | `2a63f61d2a768fb40b2c33aab59492cadb066e071581adf35ce5f72db9332e35` |
| `regolith-displayd` | `0.3.4-1-1regolith-resolute` | `6d6c84f40130ee49c406eb5031e5b5bbc4e23c3bc4e31c1b4d7d479b2b9eac27` |

The artifacts stayed in disposable `/tmp` Voulage output directories. Inputd
had no reported Lintian findings in this run. Displayd retained warnings for
missing manual pages and an empty debug-symbol file. No signing or canonical
publication was performed.

Direct extraction of both `.deb` files confirmed the packaged service units
contain the generic graphical-session ownership plus GNOME and COSMIC target
ownership, and contain the expected daemon binaries.

The pair was staged into a fresh QEMU overlay and guest SSH became ready, but
the supplied guest sudo credential was rejected before `dpkg -i`. The harness
removed the overlay and temporary files. No QEMU runtime claim was added.
