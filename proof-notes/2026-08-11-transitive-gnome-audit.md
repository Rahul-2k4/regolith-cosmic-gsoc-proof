# Transitive GNOME dependency audit

Date: 2026-08-11

This note checks the proposal requirement that the experimental COSMIC path
remove GNOME session/bootstrap and settings services, while documenting any
surviving transitive packages with a removal plan.

## Reproduction scope

Source: `regolith-session` commit
[`1fa242a`](https://github.com/Rahul-2k4/regolith-session/commit/1fa242a17aa0c173b3a77321266324bd821292ee).

The exact staged package set was simulated in disposable Ubuntu 26.04 and
Debian Trixie containers using the signed Regolith archive, local COSMIC
artifacts, and `--no-install-recommends`.

| Check | Ubuntu 26.04 | Debian Trixie |
|---|---:|---:|
| Regolith archive update | 0 | 0 |
| Exact package simulation | 0 | 0 |

## Results

Both simulations selected these GNOME-related packages:

- `gnome-keyring`
- `gnome-themes-extra`
- `gnome-themes-extra-data`

No simulated install selected `gnome-session-bin`,
`gnome-settings-daemon`, `gnome-control-center`, Mutter, or Nautilus. The
direct `Depends` list of `regolith-session-cosmic` contains no GNOME package.

The exact `regolith-session-common` package still owns these GNOME target
files:

- `usr/lib/systemd/user/regolith-gnome.target`
- `usr/lib/systemd/user/gnome-session.target.d/regolith-gnome.conf`

They are inactive on the COSMIC target, but are still installed through a
package directly required by `regolith-session-cosmic`. Criterion 9 therefore
remains **Partial** for this tuple.

## Survivor disposition

- `gnome-keyring` is mandatory through the packaged `cosmic-session` metadata.
  It is credential integration, not GNOME session bootstrap; removal requires
  a COSMIC session packaging change.
- `gnome-themes-extra` and its data package are theme resources pulled by the
  Regolith Look dependency. A COSMIC-native Look package can remove them after
  parity is available.
- `gnome-control-center` is not in the `--no-install-recommends` closure.

The follow-up candidate moves the GNOME target files into a GNOME-only package
consumed by the legacy Sway/Flashback packages. That preserves GNOME
coexistence while removing the GNOME target payload from the COSMIC dependency
path. The build, graph, and transition evidence is recorded in the
[target-split proof](2026-08-11-gnome-target-package-split.md); criterion 9
remains Partial pending mentor/release and revised-runtime review.

No completion percentage changed: strict `62-68%`, `4 of 12` fully met.
