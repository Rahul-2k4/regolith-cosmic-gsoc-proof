# Displayd runtime artifact proof - 2026-08-09

## Artifact

This proof used an isolated, unsigned `regolith-displayd` artifact built from
source commit `21e4553618cb8f0d21e46bac13a37451cb489059`.

- Package version: `0.3.4-1-1regolith-resolute`
- Artifact SHA-256: `766a2a19a5b0e478f02384ff8b0b2c35ae278789e0c7922d09eb8d6b26d161ed`
- Vendored crates: 142
- Tests: 12 passed

## Runtime result

- A live display change to `1024x768` was recorded.
- The display was restored to `1280x800`.
- One cold reboot returned to the saved state.
- `regolith-displayd` remained active with zero restarts.
- `dpkg --audit` was clean.

## Boundary

This is proof for the isolated unsigned artifact. Voulage script publication
and the full display matrix, native Settings validation, hardware validation,
and release readiness remain open. This note makes no claim about an upstream
PR or a merge to `main`.
