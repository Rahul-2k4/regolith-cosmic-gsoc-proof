# Artifact provenance

This directory holds the unsigned `.deb` files committed with the public proof
bundle. Hashes below were recomputed on 2026-08-10 with `shasum -a 256`, and the
2026-08-11 reconciled package hash was recomputed the same way.

`0.4.1-1-1regolith-resolute` and `0.4.1-2-1regolith-resolute` are Voulage-generated
version strings that were reused across successive candidate builds. Distinct
binaries therefore share one version string. Hashes recorded in individual proof
notes refer to the specific build described in that note, not to this filename in
general. The hashes below are the authoritative values for the files committed here.

## Files

| File | SHA-256 | Proof note |
|---|---|---|
| `regolith-inputd_0.4.1-1-1regolith-resolute_amd64.deb` | `ab4283c0b667104ceb231719ecb51ee8113edc09b5e2de2cda50ac210b48815d` | [Voulage current-tuple build](../proof-notes/2026-08-08-voulage-current-tuple-build.md) · [Voulage branch-tuple build](../proof-notes/2026-08-08-voulage-branch-tuple-build.md) |
| `regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb` | `759f87dc908182359a17d3930bf67b0f4c3a188fe02e75bdc71f7bd9238ff193` | [Inputd Voulage package proof](../proof-notes/2026-08-10-inputd-voulage-package-proof.md) · [Candidate verifier QEMU runtime](../proof-notes/2026-08-10-inputd-candidate-verifier-qemu-runtime.md) |
| `regolith-inputd_0.4.1-2-1regolith-resolute_reconciled-e641b43_amd64.deb` | `37f678cf76f371c08a23c971b1dd87a41f61f2c75cb27329e83b5239e7843a4e` | [Inputd Voulage repin reconciled](../proof-notes/2026-08-11-inputd-voulage-repin.md) |

## Verification

```bash
cd artifacts
shasum -a 256 *.deb
```
