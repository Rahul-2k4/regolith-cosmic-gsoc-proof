# Clean target-distro package-resolution attempt

Date: 2026-08-12

## Scope

This note records a disposable package-resolution check against clean Docker
containers for Debian Trixie and Ubuntu 26.04. It is a dependency-closure
check, not a graphical installation or runtime-session claim.

The staged local package set contained the reviewed Regolith session,
inputd, displayd, wm-config, and session-common packages. No persistent VM
disk was used or modified.

## Results

| Base | `apt-get update` | `apt-get -s --no-install-recommends install` | Result |
|---|---:|---:|---|
| `debian:trixie` | `0` | `100` | unresolved package closure |
| `ubuntu:26.04` | `0` | `100` | unresolved package closure |

The package simulation failed because the required runtime closure was not
available from the clean container repositories plus the staged local
packages.

Debian Trixie reported missing or unresolved packages including:

- `regolith-resource-loader`
- `cosmic-session`
- `regolith-look-default`
- `regolith-sway-root-config`
- `sway-regolith`
- `trawlcat`

Ubuntu 26.04 reported missing or unresolved packages including:

- `kanshi`
- `libglib2.0-0t64`
- `cosmic-session`
- `regolith-resource-loader`
- `regolith-look-default`
- `regolith-sway-root-config`
- `sway-regolith`
- `swayidle`
- `trawlcat`
- `trawld`
- `trawldb`
- `wl-clipboard`
- `gtklock`
- `xwayland`
- additional Sway dependencies

## Interpretation

This is a reproducible negative result: APT itself updated successfully, but
the current staged package set is not a complete clean target-distro
transaction. It does not prove that the source changes are unusable, and it
does not prove a clean install, graphical login, or release readiness.

The strict proposal status therefore remains **4 of 12 fully met** and
**62-68%**. The next packaging step is to supply or publish the missing
Regolith/COSMIC dependency closure, then rerun the same simulation before any
fresh graphical-install claim.
