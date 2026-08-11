# Exact inputd package build and QEMU install rollback - 2026-08-11

The exact reviewed `regolith-inputd` source was built through the personal
Voulage branch
[`rahul/cosmic-exact-tuple-local-build-20260811`](https://github.com/Rahul-2k4/voulage/tree/rahul/cosmic-exact-tuple-local-build-20260811)
at [`05dfd700`](https://github.com/Rahul-2k4/voulage/commit/05dfd7004c6941f6609a52fc4347ecdd5fa67a72).
The model pins inputd to
[`66099f67`](https://github.com/Rahul-2k4/regolith-inputd/commit/66099f67a5498f3ad10fe65ef69eb6e8b57ac0c2).

## Build

The no-sudo build completed on Linux with the opt-in apt setup gate. The
artifact was:

```text
regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb
SHA-256: 7c264412bfc3f83c29ddecae35220189aef6e4244e56c6786b1e5c82089910e8
```

The build and published copies had the same hash. Lintian returned `0`. The
build log still contains one Rust dead-code warning and the builder's existing
external 404 message; neither was presented as a zero-warning release claim.

## Disposable QEMU install

The hash-verified package was copied into the qualification guest and
installed. The guest reported:

```text
Package: regolith-inputd
Version: 0.4.1-2-1regolith-resolute
Status: install ok installed
dpkg --audit: empty
```

The installed binary hash was:

```text
60ff114ced2c42c78be8909bab85fe95686393f89e01bdec67e3718c41f3e7fc  /usr/bin/regolith-inputd
```

The guest was at the COSMIC greeter, so the user unit was inactive and no
daemon or graphical-session behavior is claimed. The guest was powered down
cleanly and the disk was restored to the existing `pre-keyinject-20260811`
snapshot.

## Boundary

This closes exact package build, hash, install, and rollback evidence. It does
not prove a fresh graphical login, live mouse reverse-sync, hardware behavior,
package signing, canonical publication, or full proposal completion.
