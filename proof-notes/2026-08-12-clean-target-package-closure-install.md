# Clean target-distro package closure and transition install

Date: 2026-08-12

This note records the positive follow-up to the earlier failed package-resolution
attempt. The earlier simulation omitted the signed Regolith archive and also
exposed a real metadata defect: `regolith-session-common` depended on the
nonexistent `regolith-resource-loader` package. The corrected source uses the
archive-provided `regolith-look-default-loader` package.

## Immutable sources

- `regolith-session` transition source: [`1fa242a`](https://github.com/Rahul-2k4/regolith-session/commit/1fa242a17aa0c173b3a77321266324bd821292ee)
- `regolith-session` branch: [`rahul/session-common-loader-transition-20260812`](https://github.com/Rahul-2k4/regolith-session/tree/rahul/session-common-loader-transition-20260812)
- Voulage local-build gate: [`49f26e1`](https://github.com/Rahul-2k4/voulage/commit/49f26e1485c4cb1c7e961b2a0939ab623ac0db8e)
- Voulage branch: [`rahul/local-build-skip-apt-build-dep`](https://github.com/Rahul-2k4/voulage/tree/rahul/local-build-skip-apt-build-dep)

The session transition contains both `Replaces: regolith-session-sway` and the
correct loader dependency. The first property prevents the known systemd-unit
file collision during package transition; the second closes the dependency
metadata against the actual Regolith archive.

## Voulage build result

The combined session source was built through the local Voulage path for:

- Ubuntu Resolute (`0.1.0-1-1regolith-resolute` style release suffix)
- Debian Trixie (`0.1.0-1-1regolith-trixie` style release suffix)

Both builds produced binary `.deb` artifacts and returned success from the
Voulage build path. Lintian still reports existing non-blocking findings in
the wider package set, including distribution/changelog and legacy package
warnings. Signing and canonical publication were not performed.

## Clean target-distro package checks

Disposable `ubuntu:26.04` and `debian:trixie` containers used the signed
Regolith archive plus the locally staged Voulage/COSMIC packages. For each
distro:

1. `apt-get update` returned exit code `0`.
2. APT simulation of the exact session, displayd, inputd, root-config,
   dbus-activation, wm-config, and COSMIC package set returned exit code `0`.
3. The actual `apt-get install -y --no-install-recommends` returned exit code
   `0`.
4. `dpkg --audit` returned no output.

The installed session packages included:

| Package | Ubuntu Resolute | Debian Trixie |
|---|---|---|
| `cosmic-session` | `1.0.0-1-1regolith-resolute` | `1.0.0-1-1regolith-resolute` |
| `cosmic-settings-daemon` | `0.1.0-1-1regolith-resolute` | `0.1.0-1-1regolith-resolute` |
| `regolith-displayd` | `0.3.4-1regolith-resolute` | `0.3.4-1regolith-trixie` |
| `regolith-inputd` | `0.4.1-1-1regolith-resolute` | `0.4.1-1-1regolith-trixie` |
| `regolith-look-default-loader` | `0.8.4-1regolith-resolute` | `0.8.4-1regolith-trixie` |
| `regolith-session-common` | `1.2.0-1ubuntu1-1-1regolith-resolute` | `1.2.0-1ubuntu1-1-1regolith-trixie` |
| `regolith-session-cosmic` | `1.2.0-1ubuntu1-1-1regolith-resolute` | `1.2.0-1ubuntu1-1-1regolith-trixie` |

The COSMIC package's direct dependency list contains the expected COSMIC
session/runtime components and does not directly pull GNOME bootstrap packages.
This does not replace the remaining transitive package audit.

## QEMU transition check

A fresh disposable overlay of the retained QEMU base was used. The combined
session packages installed with `dpkg -i`, replacing the older
`regolith-session-sway` files without the earlier collision. `dpkg --audit`
was empty before and after a guest cold reboot. The overlay was then shut down
and deleted; the canonical base image was not modified.

This is package-transition and cold-reboot evidence. It is not a new graphical
login claim: the post-reboot SSH check was outside a user graphical session,
so it did not prove `cosmic-session`, Sway, target activation, or display
behavior in this run. Existing live QEMU login evidence remains the authority
for those narrower claims.

## Interpretation

This closes the previously observed clean package-resolution failure for the
two target distributions and fixes a concrete session metadata defect. It
strengthens proposal criteria 9 and 10, but does not by itself make either
criterion fully met: the full transitive GNOME audit, signed/canonical Voulage
publication, clean graphical login, native compositor behavior, hardware
coverage, and mentor acceptance remain open.
