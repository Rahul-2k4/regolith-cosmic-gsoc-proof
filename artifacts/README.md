# Committed package artifacts

This directory holds the unsigned `.deb` files committed with the public proof
bundle. Hashes below were recomputed on 2026-08-10 with `shasum -a 256`.

`0.4.1-1-1regolith-resolute` is a Voulage-generated version string that was
reused across successive candidate builds. Four distinct binaries therefore share
one version string. Hashes recorded in individual proof notes refer to the
specific build described in that note, not to this filename in general. The
hashes below are the authoritative values for the files committed here.

## Files

| File | SHA-256 | Proof note |
|---|---|---|
| `regolith-inputd_0.4.1-1-1regolith-resolute_amd64.deb` | `ab4283c0b667104ceb231719ecb51ee8113edc09b5e2de2cda50ac210b48815d` | [Voulage current-tuple build](../proof-notes/2026-08-08-voulage-current-tuple-build.md) · [Voulage branch-tuple build](../proof-notes/2026-08-08-voulage-branch-tuple-build.md) |
| `regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb` | `759f87dc908182359a17d3930bf67b0f4c3a188fe02e75bdc71f7bd9238ff193` | [Inputd Voulage package proof](../proof-notes/2026-08-10-inputd-voulage-package-proof.md) · [Candidate verifier QEMU runtime](../proof-notes/2026-08-10-inputd-candidate-verifier-qemu-runtime.md) |

## Verification

```bash
cd artifacts
shasum -a 256 *.deb
```
