# Criterion 9 session repin audit - 2026-08-16

## Source and model

- Source branch/commit: `rahul/gnome-target-transition-replaces-20260811` / `831596f8f054a6904b0846b6a899912c6c13d465`
- Voulage branch/commit: `codex/voulage-source-pin-verifier-20260816` / `157cc5cec05753444f39120a64d04e34f141b61a`
- Model: `stage/unstable/package-model.json`, Ubuntu Resolute amd64
- Model assertion: `bash tests/regolith-session-source-pin.sh stage/unstable/package-model.json` -> `0`
- Exact `regolith-session` model ref: `831596f8f054a6904b0846b6a899912c6c13d465`

## Exact package set and hashes

Build packet: Ubuntu Resolute amd64 Voulage output

| Package | SHA-256 |
|---|---|
| `regolith-session-common_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb` | `aac5998fdeecae21dffafbf74c8519f1ff0d53c85d42d80f472d3acf38462879` |
| `regolith-session-cosmic_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb` | `84c2fdd92d490d51ef4f8250f52646263e89023880cd0bd4bb678c87d89fa1f8` |
| `regolith-session-gnome-targets_1.2.0-1ubuntu1-1-1regolith-resolute_all.deb` | `b247fdc6abcaf70706251f643dad29b4df72396f88105bdc27529a2d5e4c5cf0` |
| `regolith-session-sway_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb` | `5357b226e099cc1aa45f9b6cb40971054373a6a39bc312cd3093e29d8ff47f23` |
| `regolith-session-flashback_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb` | `c9b46ecba124c71e8144597dd1073404c3fcbcd1d80914aba7273b5236d41962` |
| `regolith-session-flashback-ext_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb` | `6f5d2e3658e4e4f85508275543f9f9fc3fb0ca9b8a4561ae1794f0fb5f453925` |

Commands run:

```text
sha256sum pkgpublish/ubuntu/resolute/regolith-session-*.deb
tests/regolith-systemd-targets.sh -> systemd target metadata: PASS
tests/regolith-session-package-audit.sh -> session package metadata: PASS
```

## GNOME dependency and ownership audit

The COSMIC package declares no GNOME bootstrap package in `Depends`,
`Recommends`, or `Suggests`; its direct dependencies are COSMIC/session,
Regolith helper, Sway, and Wayland components. The legacy Sway and Flashback
packages retain `gnome-session-bin`, `gnome-settings-daemon`, and
`gnome-flashback` as expected for GNOME coexistence.

The complete transitive closure was previously simulated with
`--no-install-recommends` in disposable Ubuntu 26.04 and Debian Trixie
containers. Surviving GNOME-related packages were `gnome-keyring`,
`gnome-themes-extra`, and `gnome-themes-extra-data`; none is session bootstrap
or GNOME settings service. The exact current source/package audit was rerun
at the direct metadata and package ownership layers above. A fresh external
APT closure rerun was not possible from this host packet because the required
archive/package pool was not staged in the current container.

Ownership inspection confirms:

- `regolith-session-gnome-targets` owns `regolith-gnome.target` and the
  `gnome-session.target.d/regolith-gnome.conf` drop-in.
- `regolith-session-cosmic` owns `regolith-cosmic.target` and
  `regolith-cosmic.desktop`.
- `regolith-session-common` owns neither GNOME target file.

Survivor justification remains: `gnome-keyring` is required by packaged
`cosmic-session` credential integration; the two theme packages are pulled by
Regolith Look resources. Removal requires replacement COSMIC-native packages,
not dependency deletion.

## QEMU attempts and boundary

The first disposable-overlay attempt timed out during the guest SSH banner
exchange before package installation. No graphical cold-login contract is
claimed for that run.

A second bounded attempt verified QEMU/HMP state, injected all six
hash-matching packages, and preserved the base image. Installation was not
claimed: the guest was Noble while the packet was built for Resolute, so
`dpkg -i` returned `1`; Sway also conflicted with the pre-existing
`regolith-sway-audio-idle-inhibit` package. The guest remained at the display
manager boundary with no graphical COSMIC session. The disposable overlay and
temporary artifacts were removed; the base remained `corrupt: false` with
SHA-256 `06776729b3d450fc8ffb5a7424a87e0a7fc63d02962ebbc7f4783d385b4b72f6`.

Status: criterion 9 remains **Partial**. The exact repin, build packet, direct
audit, ownership gate, and package hashes are proven. A fresh archive-level
closure and graphical login for the exact Resolute packet remain unproven
because the available guest is Noble and has a Sway package conflict.
