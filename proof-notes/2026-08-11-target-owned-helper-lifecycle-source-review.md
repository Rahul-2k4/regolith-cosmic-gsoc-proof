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
