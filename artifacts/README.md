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
| `regolith-inputd_0.4.1-2-1regolith-resolute_b07ea315_amd64.deb` | `2ca5f9335dc3a4d9d6fece9ef76858a4babc53d22a0b106c40390d47c3ac8399` | Inputd keyboard/input-source reverse-sync source build; QEMU installation pending |
| `regolith-inputd_0.4.1-2-1regolith-resolute_e8fce66_amd64.deb` | `650bd6f38bf67a08e140fa566aff4e7c63b2a41fc2cc60b04aada670a420823b` | Inputd pointer reverse-sync source build; QEMU installation pending |

The following six session packages were built through the reviewed Voulage
local-build path from `regolith-session` `831596f` on 2026-08-12. The canonical
model branch and the apt-build-dependency boundary are documented in the
[session repin proof](../proof-notes/2026-08-11-voulage-session-repin.md).

| File | SHA-256 |
|---|---|
| `regolith-session-common_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb` | `dfa3a8ac3e3bd859316831a88b9cc2b03fd3ace4e91af18e4cc7b88c1d2b0dd8` |
| `regolith-session-cosmic_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb` | `be3516d17b6ac2aa11776a5cbb85bf66f7894532d06c639e053ae91ae20308a6` |
| `regolith-session-gnome-targets_1.2.0-1ubuntu1-1-1regolith-resolute_all.deb` | `cf7ed94712b84247c12de87a4de47ff4445073c917f5ab74a82ef3cc739dc478` |
| `regolith-session-sway_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb` | `58c64f63ed83b8a7f467a8312614e59e9250e17cc70aaf49767ea10240213e56` |
| `regolith-session-flashback_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb` | `a1ef11a68c37168ed9e887f76499aeff3c5b2472e8b07f2a65b8964cfc2f0671` |
| `regolith-session-flashback-ext_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb` | `56fa37f6dd12662b4043a4688b39ca3bf51b01fb0b377bdc04d545678736844e` |

## Verification

```bash
cd artifacts
shasum -a 256 *.deb
```
