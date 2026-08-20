# GNOME-transitive-survivor removal plan (formal closure of the stated gap)

Date: 2026-08-20

## Which gap this closes

`09_Final_Docs/2026-08-17-proposal-to-evidence-audit.md`, Criterion 2
("Session boots with zero GNOME session/bootstrap packages"), status
`Partial`, gap as stated: *"Four GNOME-related transitive survivors remain
and need written removal plans."* This is that plan, built directly from
the live, ground-truth audit completed 2026-08-19
(`05_Testing_Proof/2026-08-19-gnome-survivor-transitive-audit.md`).

## The four survivors, individually dispositioned

| Package | Origin | Disposition | Justification |
|---|---|---|---|
| `gnome-keyring` | Hard `Depends` of `cosmic-session` | **Keep — not removable** | Declared by `cosmic-session` itself and conditionally started by its `data/start-cosmic` path for credential/SSH-agent integration. Removing it breaks a real COSMIC feature, not GNOME leakage. |
| `gnome-themes-extra` | Hard `Depends` of `regolith-session-cosmic` | **Keep — not removable** | Supplies Regolith Look assets consumed by the existing session configuration. |
| `gnome-themes-extra-data` | Hard `Depends` (data package for the above) | **Keep — not removable** | Same reasoning as `gnome-themes-extra`; it's the data half of the same package. |
| `dconf-service` / `dconf-gsettings-backend` | Hard `Depends`, confirmed 2026-08-19 | **Keep — not removable** | Real transitive `Depends` of the base install (config-storage backend consumed by cosmic-session/mutter/gjs), present even under `--no-install-recommends`, not Recommends leakage. |

All four (five counting the dconf pair separately) are genuine hard
dependency-tree members of packages COSMIC/Regolith itself needs. None are
GNOME session/bootstrap leakage in the sense Criterion 2 is actually
worried about (a stray `gnome-session`, `gdm3`, or `gnome-shell` surviving
into a COSMIC-only install).

## The separate, larger, unjustified finding — and its removal

The 2026-08-19 audit also found something *not* in the original four: an
entire GNOME desktop cascade (`gdm3`, `gnome-shell` and its variants,
`ubuntu-session`, `mutter`, `nautilus`, `gvfs`, `evolution-data-server`,
and ~290 more packages) present as **pure Recommends leakage**, traced to
one exact cause: `network-manager-applet`'s `Recommends: gnome-shell |
notification-daemon` resolving to the heavier branch. `apt-cache rdepends
--no-recommends` confirmed zero packages actually require it.

This — not the four originally-flagged survivors — was the real
GNOME-bootstrap risk Criterion 2 is about. **It is now removed at the
install-configuration level**: the mentor installer
(`scripts/install-real-system.sh`, commit `eb385d0` on
`rahul/mentor-real-system-installer-20260818`, pushed) now installs with
`--no-install-recommends`, and this was verified live: a fresh QEMU
install with the flag shows zero `gdm3`/`gnome-shell` matches in
`dpkg -l`, clean `dpkg --audit`, exit 0
(`05_Testing_Proof/2026-08-19-mentor-bundle-no-install-recommends-followup.md`).

## Disposition of Criterion 2

- The four originally-flagged survivors: individually justified, kept,
  written up above — this satisfies "written removal plan" for each (the
  plan being: justified as a real dependency, not removed).
- The actual unjustified GNOME cascade: identified, root-caused, and
  removed via a verified install-configuration fix, not a documentation
  promise.
- Remaining honest gap: the fix was verified on the disk this session
  built and tested. It has **not yet been verified together with the
  separate `regolith-inputd` XDG env-import fix on the same boot** — see
  `05_Testing_Proof/2026-08-19-gnome-survivor-transitive-audit.md`'s
  closing note. A single combined verification run (both fixes, one boot,
  full runtime health check) is the one remaining step before this
  criterion can honestly be called `Met` rather than `Partial (strong)`.

## Recommendation

Given the above, Criterion 2 should move from `Partial` to **`Partial
(strong)`** effective now — real removal plan written, real cascade fix
verified independently — and to `Met` once the one remaining combined
verification run (GPU fix + inputd fix + `--no-install-recommends`, all
together, one QEMU boot) comes back clean. That run is locally actionable
and does not depend on any external party.
