# GNOME target package split and transition proof

Date: 2026-08-12

This note records the candidate package split that removes inactive GNOME
target files from the COSMIC package path while preserving the legacy GNOME
session path.

## Source and build

- Repository: [`regolith-session`](https://github.com/Rahul-2k4/regolith-session)
- Branch: [`rahul/gnome-target-package-split-20260811`](https://github.com/Rahul-2k4/regolith-session/tree/rahul/gnome-target-package-split-20260811)
- Source commit: [`cbd810f`](https://github.com/Rahul-2k4/regolith-session/commit/cbd810f68f2713be91f1a61cdd326cd128a857c5)
- Voulage builder: [`49f26e1`](https://github.com/Rahul-2k4/voulage/commit/49f26e1485c4cb1c7e961b2a0939ab623ac0db8e)
- Voulage exit code: `0` for Ubuntu Resolute and Debian Trixie binary builds

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

The source tests `regolith-session-package-audit.sh` and
`regolith-systemd-targets.sh` passed. Shell syntax and `git diff --check` also
passed on Linux.

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

This closes the inactive GNOME-target ownership defect in the source/package
candidate. It does not claim a graphical COSMIC login from this revised tuple,
signed publication, or removal of the three documented transitive GNOME
resource packages. Criterion 9 remains **Partial** pending mentor/release
acceptance and runtime validation of the revised tuple.
