# Mentor seven-package bundle: `--no-install-recommends` follow-up closed

Date: 2026-08-19

## Scope

Direct follow-up to the explicit flag left in
`05_Testing_Proof/2026-08-18-ubuntu-2604-resolute-first-package-closure.md`:
"Rerun with `--no-install-recommends` next time" after the plain
`apt-get install -y` install of the mentor seven-package bundle pulled in
`gdm3`/`gnome-shell` as an unpinned Recommends on Ubuntu 26.04 Resolute,
worked around mid-run by installing greetd and disabling gdm3.

## Method

Fresh disposable overlay of `ubuntu-26.04-resolute-qual.qcow2` (never booted
or modified directly), fresh ed25519 keypair + password injected offline via
`virt-customize`, booted with `-device virtio-gpu-pci -display none`.

The base disk already had the mentor bundle (and the resulting
gdm3/gnome-shell) installed from the 2026-08-18 run baked in. To actually
test the flag rather than no-op over an already-dirty state, the overlay was
reset first: purged all 7 mentor-bundle packages plus `gdm3`/`gnome-shell`
and their orphaned dependents, confirmed `dpkg --audit` clean on the reset
state. One real gotcha surfaced here, worth remembering for any future purge
of gdm3 on this line of disks: **removing the `gdm3` package resets
`/etc/systemd/system/display-manager.service` to point at (now-dangling)
`gdm3.service`**, even though greetd owned that alias before the purge —
gdm3's maintainer scripts manage that symlink unconditionally whenever
they run, not only on install. Fixed with a plain
`systemctl disable greetd.service && systemctl enable greetd.service`,
which correctly re-points the alias. This is a property of gdm3's packaging,
not of `--no-install-recommends` — noted so a future session doesn't
mistake it for a new bug in the mentor bundle.

The verified 7-package bundle (hashes re-checked against
`mentor-test-2026-08-18.sha256` on the Mac, on the remote host, and inside
the guest — all three matched) was then installed with:

```
sudo apt-get install --no-install-recommends -y ./*.deb
```

## Result

- **Install exit 0.** Notably, this run's Recommends list (`xdg-desktop-portal-cosmic`,
  `cosmic-comp`, `cosmic-panel`, ... `regolith-wm-rofication-ilia`, etc.)
  does not even mention `gdm3` or `gnome-shell` — with the flag applied none
  of the 25+ recommended packages are pulled in, only the 7 bundle packages
  plus their one hard dependency (`cosmic-session`).
- `sudo dpkg --audit` → clean, exit 0.
- `dpkg -l | grep -E 'gdm3|gnome-shell'` → **no matches** (grep exit 1).
  **This is the bug fix confirmed**: `gdm3`/`gnome-shell` were a Recommends,
  not a real dependency, and `--no-install-recommends` avoids them entirely.
- `systemctl status display-manager.service` → resolves to `greetd.service`,
  `active (running)`.
- greetd IPC login (same `greetd-session-cosmic-client.py` client as every
  prior proof in this project) → `CANCEL_REPLY success` → `REPLY
  auth_message` → `REPLY success` → `START_REPLY success`, exit 0.
- Post-login: `regolith-cosmic.target` reached then immediately stopped
  (`inactive`); `systemctl --user list-units --failed` → 0 failed units;
  `pgrep -a sway` → no match (exit 1); `pgrep -a cosmic` → `cosmic-session`
  process alive, running
  `regolith-session-cosmic-runtime sway -c /etc/regolith/sway/config`.
  This is the same already-diagnosed cosmic-comp/Sway-not-installed-under
  `--no-install-recommends` + separate compositor-crash behavior documented
  in `2026-08-19-ubuntu-2604-resolute-gpu-fix-new-blocker.md` — expected,
  not a new finding, and explicitly out of scope for this follow-up.

## What this does and does not change

Closes the specific, narrow follow-up flagged on 2026-08-18: confirms
`gdm3`/`gnome-shell` came in purely as unpinned Recommends and that
`--no-install-recommends` avoids them with no other side effects (clean
audit, greetd untouched, login still succeeds). Does **not** touch the
separate, already-tracked cosmic-comp/Sway crash question or the
`regolith-inputd` GNOME-feature-mismatch bug — both remain exactly as
documented in `2026-08-19-ubuntu-2604-resolute-gpu-fix-new-blocker.md`.
Does not change the strict ledger score.

## Cleanup

QEMU stopped cleanly via HMP `system_powerdown`; overlay
(`followup-noinstallrecommends-20260819.qcow2`) deleted; all credential
scratch files (`id_ed25519`, `id_ed25519.pub`, `pass.txt`, `pw.txt`,
`known_hosts`) shredded and the scratch directory removed. Base disk
sha256 confirmed identical before and after:
`a2c089fd5bf33b310057759abb04eb06f72faa10699f109ff416d2a8a300d226`.
