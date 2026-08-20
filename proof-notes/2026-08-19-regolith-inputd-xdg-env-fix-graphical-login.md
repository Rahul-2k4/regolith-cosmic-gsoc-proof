# regolith-inputd XDG_CURRENT_DESKTOP env-import bug: root-caused, fixed, verified live — full graphical COSMIC login reached on Resolute

Date: 2026-08-19

## Scope

Direct follow-up to `05_Testing_Proof/2026-08-19-ubuntu-2604-resolute-gpu-fix-new-blocker.md`,
which left two open problems after the GPU/DRM fix: a `cosmic-comp`/Sway
exit-code-1 crash (still open, untouched — see below), and a `regolith-inputd`
failure: `"GNOME input backend selected, but regolith-inputd was built
without the gnome feature"`.

## Root cause (confirmed live, not just static analysis)

`regolith-init-inputd.service` is a systemd `--user` unit. Such units only
see environment variables explicitly pushed into the user manager via
`systemctl --user import-environment` — not whatever the login session's own
process environment happens to hold. The COSMIC runtime wrapper
(`usr/lib/regolith/regolith-session-cosmic-runtime`) imported
`WAYLAND_DISPLAY` and `SWAYSOCK` but never `XDG_CURRENT_DESKTOP`.

Confirmed on a live disposable QEMU overlay (never touching the base disk):
after a real greetd login, `systemctl --user show-environment | grep
XDG_CURRENT_DESKTOP` returned nothing, even though the login session's own
process environment correctly had
`XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`. `regolith-inputd`'s own
`backend.rs` correctly defaults to `BackendKind::Gnome` when the variable is
absent from its process environment — that fallback is not itself a bug.
But because the mentor bundle's installed `regolith-inputd` binary
(`0.4.1-2`) is genuinely COSMIC-only (confirmed via `ldd` on the guest:
only `libgcc_s.so.1`/`libc.so.6`, no `libgio`/`libglib`/`dconf` — by design,
not by build mistake), the Gnome-fallback path hits a hard compile-time
`#[cfg(not(feature = "gnome"))]` error arm, producing exactly the observed
message.

A second candidate defect (the shipped binary missing the `gnome` feature
by build mistake) was directly **falsified**: `strings`/`ldd` confirmed the
binary is correctly COSMIC-only; there is no packaging/feature-flag bug.
The entire failure is the single env-import gap above.

## Fix

`usr/lib/regolith/regolith-session-cosmic-runtime`: added
`XDG_CURRENT_DESKTOP` to the same `systemctl --user import-environment` and
`unset-environment` calls that already carried `WAYLAND_DISPLAY SWAYSOCK`,
mirroring the existing `cbb4e4c` pattern. Updated
`tests/regolith-cosmic-runtime-environment.sh` and
`tests/regolith-systemd-targets.sh` to assert `XDG_CURRENT_DESKTOP` is
present in both calls. All five test scripts under `tests/` in the
`regolith-session` repo pass (exit 0) after this change.

Commit `6cc2f9f` on branch `rahul/regolith-session-inputd-xdg-env-20260819`,
pushed to `https://github.com/Rahul-2k4/regolith-session` (not yet merged —
no PR opened yet, this is a proof-of-fix branch pending review). Author
identity confirmed correct: `Rahul Tripathi <rahultripathi7009@gmail.com>`.

## Live verification

Before fix (disposable overlay, fresh greetd login):
```
$ systemctl --user show-environment | grep XDG_CURRENT_DESKTOP
(nothing)
$ journalctl --user -u regolith-init-inputd.service
ERROR regolith_inputd > Failed to connect to Sway IPC during startup:
GNOME input backend selected, but regolith-inputd was built without the
gnome feature
regolith-init-inputd.service: Main process exited, code=exited, status=1/FAILURE
```

After fix (fresh overlay, patched runtime script uploaded via
`virt-customize`, fresh greetd login):
```
$ systemctl --user show-environment | grep XDG_CURRENT_DESKTOP
XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
$ systemctl --user status regolith-init-inputd.service
Active: active (running)
$ systemctl --user list-units --failed
0 loaded units listed.
$ pgrep -a sway
sway -c /etc/regolith/sway/config
swaybg
swayidle -w timeout 300 gtklock
$ swaymsg -t get_workspaces
[]
$ systemctl --user is-active regolith-cosmic.target
active
```

**This is, for the first time in this project, a fully healthy graphical
COSMIC session reached on Ubuntu 26.04 Resolute in one run** — inputd
active, no failed units, a live compositor, a working Sway IPC query, and
the COSMIC target active, all observed together in the same boot.

## What this does and does not prove

This is a real fix for a real, precisely diagnosed bug, verified with
before/after live evidence — not a rounded-up or assumed success. It does
**not** mean the Sway/`cosmic-comp` exit-code-1 crash documented in the
2026-08-19 GPU-fix note is generally solved: that crash was intermittent
on this exact disk/build in the prior attempt, and this run's clean
compositor start should be read as "one healthy run, with the inputd bug
now provably fixed," not as "the sway crash is resolved" — that issue was
not investigated or touched in this pass and remains open. Repeated runs
would be needed to see whether the sway crash recurs now that inputd no
longer fails alongside it.

The strict ledger: this is real forward progress on the same
already-`Partial` Criterion 9 — a full graphical login was reached at
least once, with root cause and fix in hand for one of the two blockers.
It is reasonable to consider nudging Criterion 9 status language given a
directly observed, verified graphical session, but the disposition (still
`Partial`, or now `Met` for a specific tuple/disk state) should be decided
against the exact proposal wording, not assumed here. Recommend treating
this as **strong new evidence for Criterion 9**, pending one more clean
repeat run to rule out the sway crash being purely intermittent luck
rather than genuinely resolved as a side effect of this fix.

## Next steps

- Open a PR for branch `rahul/regolith-session-inputd-xdg-env-20260819` once
  reviewed.
- ~~Rerun this exact sequence 1-2 more times~~ — done, see addendum below.

## Addendum, 2026-08-19: repeat-run check (2 more independent boots)

Two more fully independent fresh-overlay/fresh-boot/fresh-login runs were
done with the patched runtime script, specifically to check whether the
separate sway/cosmic-comp exit-code-1 crash (documented in
`2026-08-19-ubuntu-2604-resolute-gpu-fix-new-blocker.md`) still occurs now
that inputd no longer fails alongside it.

**Both runs came back completely clean** — same six checks as the original
run, all healthy, zero occurrences of the exit-1/137 crash signature in
`journalctl`. Run 2 went slightly further than run 1 and positively
confirmed a working `swaymsg -t get_workspaces` IPC query (run 1's IPC
check was inconclusive only because `SWAYSOCK` wasn't exported in the bare
probing shell, not because the compositor was unhealthy — `pgrep`
confirmed it was alive in both runs).

**That's 3 consecutive clean boots total** (1 original + these 2). Read
this honestly: 3 clean runs in a row is real, positive evidence, but it is
**not proof** the crash is fixed — the original crash's failure rate was
never quantified, so 3 clean boots would look identical whether the bug is
gone or was, say, 1-in-5 intermittent. All 3 runs also shared the same
overlay lineage, host, and QEMU flags, so no different load/timing
conditions were exercised. This should be read as **strong incremental
evidence toward "resolved as a side effect of the XDG_CURRENT_DESKTOP
fix"** (plausible mechanism: removing the concurrent inputd failure
removed a startup race), not as a closed question.

Cleanup fully confirmed: both overlays and all generated credentials
deleted, base disk sha256 unchanged before/after
(`a2c089fd5bf33b310057759abb04eb06f72faa10699f109ff416d2a8a300d226`).

**Recommendation:** proceed with opening the PR for the inputd fix on its
own merits (it fixes a real, confirmed bug regardless of the sway crash's
status). Do not yet claim the sway crash is "fixed" in any mentor-facing or
public text — call it "not reproduced in 3 consecutive runs since the
inputd fix" if it needs to be mentioned at all. Leave the strict ledger at
**62-68%, 5/12** for now; revisit Criterion 9's status only if further runs
(ideally under different load/timing conditions, not just repeats of the
same setup) keep coming back clean.
