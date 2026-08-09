# Cosmolith package and QEMU installation boundary - 2026-08-09

## Scope

This note records the package build and installation result for the cosmolith
candidate. It does not claim a fresh-session runtime pass.

## Build result

The pinned Voulage clean-clone build completed vendoring, offline Cargo
compilation, Debian source-package generation, and binary package creation.
The final command returned `25` only when `debuild` attempted to sign with a
builder identity whose GPG secret key was unavailable.

Produced package:

`cosmolith_0.1.0-1-1regolith-resolute_amd64.deb`

SHA-256:

`2f12ecce616b2e4ae47577a4c23d81e3f4ddbdfe735b5e13b75beec3cd29b642`

The package contains `/usr/bin/cosmolith` and its manual page. Lintian
reported no errors; three warnings remain for the `pkg-config` build
dependency, an empty dbgsym package, and the Standards-Version metadata.

## QEMU installation

The exact package was installed in the qualification QEMU guest. The copied
and guest SHA-256 values matched, `dpkg -i` returned `0`, the installed version
was `0.1.0-1-1regolith-resolute`, and `dpkg --audit` was empty.

## Runtime boundary

The post-install check found the package installed but no running `cosmolith`
process because the guest was not in an active COSMIC session at that moment.
This proves installation, not fresh-login launch, packaged config-change
behavior, signing, or canonical publication.
