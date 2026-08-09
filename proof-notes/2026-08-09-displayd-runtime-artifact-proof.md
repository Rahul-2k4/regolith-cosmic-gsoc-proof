# Displayd runtime artifact proof - 2026-08-09

## Installed runtime artifact

The QEMU runtime proof used this isolated, unsigned `regolith-displayd`
package. This is the installed/runtime artifact, not the later clean Voulage
build artifact recorded below.

- Package version: `0.3.4-1-1regolith-resolute`
- Artifact SHA-256: `766a2a19a5b0e478f02384ff8b0b2c35ae278789e0c7922d09eb8d6b26d161ed`
- Source commit: `21e4553618cb8f0d21e46bac13a37451cb489059`

## Runtime result

- A live display change to `1024x768` was recorded.
- The display was restored to `1280x800`.
- One cold reboot returned to the saved state.
- `regolith-displayd` remained active with zero restarts.
- `dpkg --audit` was clean.

## Clean Voulage build artifact

The clean Voulage build used the following immutable inputs and produced a
separate package artifact. No source override was used.

- Voulage commit: `021d4e4d4c758df1078c7b5fe55c8d38b455e5fa`
- Source commit: `21e4553618cb8f0d21e46bac13a37451cb489059`
- Package version: `0.3.4-1-1regolith-resolute`
- Build artifact SHA-256: `9c88f6fef0bce9ca5adb68b5f6b52814efd3042e0dfabedccb81fe27d0d63714`
- Vendored crates: 142
- Tests: 12 passed
- `BUILD_RC=0`
- Lintian: non-clean; warnings remain.

This clean build artifact was not installed for the QEMU runtime checks above.
The runtime claims therefore remain tied to the installed artifact SHA
`766a2a19a5b0e478f02384ff8b0b2c35ae278789e0c7922d09eb8d6b26d161ed`.

## Boundary

The exact live and cold QEMU proof is limited to the installed artifact above.
The full display matrix, native Settings validation, hardware validation,
lintian cleanup, signing, and release readiness remain open. This note makes
no claim about an upstream PR or a merge to `main`.
