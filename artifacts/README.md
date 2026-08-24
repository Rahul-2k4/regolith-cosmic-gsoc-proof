# Artifact provenance

This directory holds the unsigned `.deb` files committed with the public proof
bundle. Hashes below were recomputed on 2026-08-10 with `shasum -a 256`, and the
2026-08-11 reconciled package hash was recomputed the same way. The
`regolith-session-common` entries dated 2026-08-18 were recomputed on that
date, independently of the earlier batch.

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
| `regolith-inputd_0.4.1-2-1regolith-resolute_e8fce66_amd64.deb` | `650bd6f38bf67a08e140fa566aff4e7c63b2a41fc2cc60b04aada670a420823b` | [Inputd pointer reverse-sync source build](../proof-notes/2026-08-23-inputd-pointer-reverse-sync-source.md) · [final QEMU cold-login proof](../proof-notes/2026-08-23-inputd-cosmic-cold-login-final.md) |

| `regolith-displayd_0.3.4-1_48025e3_amd64.deb` | `4d410cc022ecdcd497ce48d94e05ba4464dacddb75ea15dd57d033334ec4e601` | [COSMIC Wayland apply source proof](../proof-notes/2026-08-23-displayd-cosmic-wayland-apply-source.md) · [QEMU package/runtime proof](../proof-notes/2026-08-23-displayd-cosmic-wayland-apply-qemu.md) |

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

`regolith-session-common_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb` (SHA-256
`bcf78bba...`, listed in an earlier draft of the mentor-test manifest) is
**superseded and must not be used**: its version string sorts lower than the
`-1-1regolith-resolute` build above, which caused a real `apt` downgrade
abort in QEMU. The corrected replacement is the `regolith-session-common`
row in the table below.

## Mentor seven-package tuple (current bundle, refreshed 2026-08-24)

This is the current exact bundle `scripts/install-real-system.sh` installs.
The fresh QEMU install→reboot→greetd-login evidence is recorded in the proof
note linked below. All seven files live at `mentor-seven-package-bundle/` in this
directory, not at the top level — the installer's `--package-dir` mode
refuses to run against a folder containing any `.deb` file outside its
manifest, and the top-level `artifacts/` folder also holds older historical
builds. One filename here is a byte-identical duplicate of a package name
listed elsewhere in this file at a different hash: `regolith-inputd_0.4.1-2-*`
is a **different binary** from the one in the tables above, despite the
identical filename. Use the hash, not the filename, to know which build a
given proof note is describing.

`regolith-session-cosmic_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb`
(SHA-256 `8e3559e8...`) shipped in this bundle through 2026-08-18 carries
the exact same version-ordering defect fixed in `regolith-session-common`
above: its version string sorts lower than a stale pre-installed build,
which would cause the identical `apt` downgrade-refusal failure. It is
**superseded and must not be used**. The historical replacement,
`regolith-session-cosmic_1.2.0-1ubuntu1-2-1regolith-resolute_amd64.deb`
(SHA-256 `790dbb85cd49b19930edca9c52a6f1157f0bd7cd4b97629faa8a55fe4a25957d`),
was built from the same Voulage run that fixed `-common` (branch
`rahul/session-common-version-fix-20260818`, commit `b6c4478`) but was
never staged into this bundle until now. Confirmed via
`dpkg --compare-versions` that the new version sorts above the stale
baseline that triggered the original `-common` bug. The other four
sibling packages built from the same source (`-flashback`,
`-flashback-ext`, `-gnome-targets`, `-sway`) are not part of this bundle
and carry no live shipping risk today.

| File | SHA-256 | Proof note |
|---|---|---|
| `regolith-session-cosmic_1.2.0-1ubuntu1-4-1regolith-resolute_amd64.deb` | `3e2c58752fd4cd65ca710f8db440434bdc4eed0641c2753f31aa4686e35539a7` | [Fresh QEMU evidence](../proof-notes/2026-08-21-cosmic-not-found-fix-correct-lineage-qemu.md) |
| `regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb` (a277811b build, distinct from the `759f87dc` build above sharing this filename) | `a277811b7843791b3556f2bbb0d5c5a600b483f41f34d71f5f75cad08886aa19` | [Fresh QEMU evidence](../proof-notes/2026-08-21-cosmic-not-found-fix-correct-lineage-qemu.md) · historical [Mentor seven-package tuple QEMU runtime](../proof-notes/2026-08-18-mentor-seven-package-tuple-qemu-runtime.md); no proof note documents this exact build in isolation |
| `regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb` | `949b9aedf8b4e64f2feeabc67947e7a64d6ca0cfb810e11a87896fb654afea1d` | [Fresh QEMU evidence](../proof-notes/2026-08-21-cosmic-not-found-fix-correct-lineage-qemu.md) · historical [Mentor seven-package tuple QEMU runtime](../proof-notes/2026-08-18-mentor-seven-package-tuple-qemu-runtime.md); no proof note documents this exact build in isolation |
| `cosmolith_0.1.0-1-1regolith-resolute_amd64.deb` | `ad5af5edee6d278c4b9990c02f13ea3b715e260686cc6b58f2f5c48f6e6bb04e` | [Fresh QEMU evidence](../proof-notes/2026-08-21-cosmic-not-found-fix-correct-lineage-qemu.md) · [Displayd COSMIC Kanshi guard runtime](../proof-notes/2026-08-18-displayd-kanshi-guard-runtime.md) (historical reboot+login proof, 5-package combination) |
| `cosmic-settings_1.0.12-1-1regolith-resolute_amd64.deb` | `5459b91e7d5281ff0727cef8431a31a7e1dc4a70031da855984938068563d29f` | [Fresh QEMU evidence](../proof-notes/2026-08-21-cosmic-not-found-fix-correct-lineage-qemu.md) · [Displayd COSMIC Kanshi guard runtime](../proof-notes/2026-08-18-displayd-kanshi-guard-runtime.md) (historical reboot+login proof, 5-package combination) |
| `cosmic-settings-daemon_0.1.0-1-1regolith-resolute_amd64.deb` | `16dbe4a274d31080055a6f0a2699f9b9d0d1a542c44798c9724ff3a0bfbb2fe1` | [Fresh QEMU evidence](../proof-notes/2026-08-21-cosmic-not-found-fix-correct-lineage-qemu.md); a *different* build of this package (hash `e10c88b9...`) has its own [Lintian closure note](../proof-notes/2026-08-16-cosmic-settings-daemon-lintian-closure.md), which does not describe this hash |

## Verification

```bash
# Historical builds at the top level:
cd artifacts
shasum -a 256 *.deb

# The mentor seven-package bundle, against its own manifest:
cd mentor-seven-package-bundle
shasum -a 256 -c ../mentor-test-2026-08-18.sha256
```
