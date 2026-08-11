# Direct session package metadata audit - 2026-08-12

The executable `scripts/audit-session-package-metadata.sh` audits the Debian
control metadata of one or more session packages. It prints the requested
control fields and rejects only direct `Depends`, `Recommends`, or `Suggests`
entries on `regolith-session-cosmic` that name a GNOME bootstrap package or
`kanshi`.

Example command shape:

```sh
scripts/audit-session-package-metadata.sh path/to/regolith-session-cosmic.deb path/to/regolith-session-sway.deb
```

This is direct package-metadata evidence only. It is not a claim about the
transitive dependency closure resolved by APT. GNOME dependencies in
`regolith-session-sway` and `regolith-session-flashback` are intentionally not
rejected by this audit.

## Linux execution

The audit was run against the staged Resolute packages for
`regolith-session-common`, `regolith-session-cosmic`, `regolith-session-sway`,
`regolith-session-flashback`, and `regolith-session-gnome-targets`. It exited
with status `0`.

The COSMIC package declares `cosmic-session`, Regolith input/display helpers,
and COSMIC settings components, but no direct GNOME bootstrap package and no
`kanshi`. The Sway and Flashback packages retain their GNOME dependencies,
which is expected for GNOME coexistence. The split package contains the GNOME
target files and replaces their former ownership in the common/Sway packages.

The same final package tuple was then installed in a disposable QEMU overlay.
Installation returned `0`; after reboot, greetd started the COSMIC/Sway session,
`regolith-cosmic.target` and both target-owned helper units were active,
`regolith-gnome.target` was inactive, and `dpkg --audit` was empty. This closes
the package-to-graphical-login integration subgate, not the full transitive
APT closure or native hardware validation.
