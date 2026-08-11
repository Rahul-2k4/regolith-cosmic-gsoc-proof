# GNOME target package split and transition proof

Date: 2026-08-12

This note records the candidate package split that removes inactive GNOME
target files from the COSMIC package path while preserving the legacy GNOME
session path.

## Source and build

- Repository: [`regolith-session`](https://github.com/Rahul-2k4/regolith-session)
- Branch: [`rahul/gnome-xorg-dependency-split-20260811`](https://github.com/Rahul-2k4/regolith-session/tree/rahul/gnome-xorg-dependency-split-20260811)
- Source commit: [`641f796`](https://github.com/Rahul-2k4/regolith-session/commit/641f796cd193b1c5f6359b02703386e1807a1bb6) (parent target split: `cbd810f`)
- Voulage builder: [`49f26e1`](https://github.com/Rahul-2k4/voulage/commit/49f26e1485c4cb1c7e961b2a0939ab623ac0db8e)
- Voulage wrapper status: staging reached, but the local build stopped at
  `sudo apt build-dep` after an archive `404`; it did not produce a Voulage
  release artifact for this exact branch.
- Manual `dpkg-buildpackage -b -us -uc`: exit `0`; all six packages were
  produced.

The source adds `regolith-session-gnome-targets`, moves these files out of
`regolith-session-common`, and makes the legacy Sway and Flashback packages
depend on the new GNOME-only package. `regolith-session-cosmic` does not
depend on it.

## Package evidence

For both Ubuntu Resolute and Debian Trixie:

- `regolith-session-common` has no GNOME target payload.
- `regolith-session-gnome-targets` owns exactly:
  - `usr/lib/systemd/user/regolith-gnome.target`
  - `usr/lib/systemd/user/gnome-session.target.d/regolith-gnome.conf`
- The legacy Sway package depends on `regolith-session-gnome-targets`.
- The COSMIC package depends on `regolith-session-common`, not the GNOME-only package.

The source package-audit and systemd tests, including the new assertion that
Flashback does not depend on either `xorg` or `xserver-xorg`, passed. All nine
session tests, shell syntax, and `git diff --check` passed on Linux.

The manually built target package was
`regolith-session-gnome-targets_1.2.0-1ubuntu1-1-1regolith-resolute_all.deb`
with SHA-256
`271a99ed9bb20cd12ab3af5bc0977492279a67663835c62c4bb0c168208e0558`.
Lintian exited `0` for the rebuilt package family, with warnings only. The
previous real `Depends: xorg` error is closed on this branch.

## Transition and dependency graph

Disposable Ubuntu 26.04 and Debian Trixie simulations with
`--no-install-recommends` both returned:

```text
APT_UPDATE_RC=0
APT_SIMULATION_RC=0
```

The only GNOME-related packages selected were `gnome-keyring`,
`gnome-themes-extra`, and `gnome-themes-extra-data`. No GNOME session manager,
settings daemon, control center, Mutter, or Nautilus was selected. These
survivors remain documented as transitive dependencies of `cosmic-session` or
Regolith theme resources and are not claimed removed by this patch.

An old `regolith-session-common` package was unpacked first, followed by the
new common and GNOME-target packages, in disposable Ubuntu and Trixie
containers. Both transitions returned `TRANSITION_PASS`; the two target files
were present and `dpkg-query -S` assigned both to
`regolith-session-gnome-targets`. The isolated test used
`--force-depends` only while configuring the common package because unrelated
Regolith runtime dependencies were not installed in the minimal container.

## Boundary

This closes the inactive GNOME-target ownership defect and the Flashback
metapackage dependency in the source/package candidate. It does not claim a
graphical COSMIC login from this revised tuple,
signed publication, or removal of the three documented transitive GNOME
resource packages. Criterion 9 remains **Partial** pending mentor/release
acceptance and runtime validation of the revised tuple.
