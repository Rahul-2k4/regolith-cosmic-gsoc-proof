# GNOME-survivor transitive dependency audit (full tuple)

Date: 2026-08-19

## Scope

Criterion 9 in `01_Proposal_Alignment.md`: **"Package audit: GNOME
session/bootstrap removed, survivors justified"** — status `Partial`,
with the gap explicitly noted as "survivor justification/transitive audit
open." Only `gnome-keyring`, `gnome-themes-extra`, and
`gnome-themes-extra-data` had been examined and justified before today
(`08_Blockers/2026-08-12-cosmic-session-dependency-scope-decision.md`).
This closes that gap for the full installed tuple: base Ubuntu 26.04
Resolute + `regolith-session-cosmic` + the mentor seven-package bundle.

## Method

Booted a disposable overlay of the existing qual disk (base disk untouched,
sha256 confirmed unchanged before/after:
`a2c089fd5bf33b310057759abb04eb06f72faa10699f109ff416d2a8a300d226`).
Rather than simulate a dependency trace, read `/var/log/apt/history.log`
directly on the guest — the literal, already-recorded APT transactions
that built this exact disk. That's ground truth for what pulled what in,
not a reconstruction.

## Findings

**Already justified (2026-08-12 record, reconfirmed unaffected):**
`gnome-keyring`, `gnome-themes-extra`, `gnome-themes-extra-data` — genuine
hard `Depends` of `regolith-session-cosmic` itself, present even in the
`--no-install-recommends` transaction. Unchanged conclusion.

**New, also justified:** `dconf-service`, `dconf-gsettings-backend` — same
transaction, same reasoning: real transitive `Depends`, not Recommends
leakage.

**New, and NOT justified — a real, traceable defect:** a *separate*
transaction — installing the mentor seven-package bundle with
`apt-get install -y --allow-downgrades` (no `--no-install-recommends`,
default `APT::Install-Recommends "1"`) — pulled in the entire GNOME
desktop stack as a side effect: `gdm3`, `gnome-shell` (+ variants),
`ubuntu-session`, `gnome-control-center`, `mutter`, `nautilus`, `gvfs`,
`gnome-online-accounts`, `gnome-remote-desktop`, `rygel`,
`evolution-data-server`, the Bluetooth/GNOME stack, and roughly 260 more
packages in the same dependency web (webkit2gtk, printing/scanning,
geoclue, colord, ibus, tracker, etc.) — all marked `apt-mark auto`, none
manually requested.

**Exact traced root cause:** `cosmic-settings` hard-`Depends:
network-manager-gnome`, which hard-`Depends: network-manager-applet` (both
genuine — COSMIC's network panel needs this). But
`network-manager-applet`'s own `Recommends: gnome-shell | notification-daemon`
(an OR-alternative) resolved to the heavier `gnome-shell` branch purely
because Recommends were enabled and nothing had already satisfied the
lighter alternative. Confirmed via `apt-cache show network-manager-applet`
and `apt-cache rdepends --installed --no-recommends ... gdm3` returning
**zero** strict reverse-dependencies — nothing in the tuple actually
requires `gdm3`/`gnome-shell`. `dpkg -l` confirms they're still installed
(`ii`) even though `display-manager.service` correctly points at greetd —
dead weight on disk, not just disabled.

## What this does and does not prove

This confirms, with ground-truth transaction logs rather than
documentation claims, that the GNOME-desktop cascade seen in the
2026-08-18 Resolute proof note was real, is still live on the current base
disk, and has one precise, traceable root cause (a Recommends
OR-alternative, not a hard dependency). It does **not** by itself remove
anything, change any install script, or re-verify that COSMIC still
reaches a healthy graphical session without the cascade — that
verification is being run separately today as a direct rerun with
`--no-install-recommends`. Strict ledger unchanged: this strengthens the
already-`Partial` Criterion 9 with a completed transitive audit and a
named fix, not yet a promotion to `Met` pending that rerun's result.

## Side finding, flagged not fixed

This same disk shows `gnome-session-bin` installed (`ii`), which sits
awkwardly next to Criterion 2's "Met" claim of `gnome-session-bin`
absence. Not a contradiction on inspection — that claim was proven on a
different tuple/distro (Pop!_OS), not this Ubuntu 26.04 + mentor-bundle
combination — but worth an explicit note in `01_Proposal_Alignment.md` so
Criterion 2's "Met" status isn't read as universal across every tuple this
project has tested. Flagging only; not editing that criterion's status
here.

## Next step — done

The `--no-install-recommends` rerun completed: exit 0, `dpkg --audit`
clean, `dpkg -l | grep -E 'gdm3|gnome-shell'` returns no matches, greetd
stays the active display manager throughout. See
`05_Testing_Proof/2026-08-19-mentor-bundle-no-install-recommends-followup.md`
for the full run. Criterion 9's survivor list is now: `gnome-keyring`,
`gnome-themes-extra(-data)`, `dconf-service`, `dconf-gsettings-backend` —
all justified, GNOME cascade eliminated.

The mentor-facing installer script itself
(`scripts/install-real-system.sh` in the
`mentor-real-system-installer-20260818` worktree) still ran plain
`apt-get install -y` with no such flag — a live regression risk for
anyone actually running it. Fixed directly: commit `eb385d0` on
`rahul/mentor-real-system-installer-20260818` (pushed), adds
`--no-install-recommends`, updates the matching contract-test assertions.
Contract test passes.

Note: the compositor did not reach a healthy running state in the
no-install-recommends rerun (`regolith-cosmic.target` stopped after
reaching, no live `sway` process) — expected and not a regression, since
that overlay used the base disk's original, unpatched runtime script, not
today's separate `XDG_CURRENT_DESKTOP` fix (see
`2026-08-19-regolith-inputd-xdg-env-fix-graphical-login.md`). The two
fixes haven't yet been verified together on the same boot.
