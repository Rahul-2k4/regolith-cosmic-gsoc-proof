# Fresh-overlay COSMIC-only install: is cold-login ordering gated by session identity?

Date: 2026-08-21 (IST) / guest boots 2026-08-21 13:2x-13:4x UTC
Kind: **QEMU proof.** Nothing here ran on real hardware, and the guest ran
headless (`-display none`), so no check below is a claim about pixels.

Target: proposal Criterion 3, "Cold-login ordering is gated by session
identity", currently `Partial` in
`09_Final_Docs/2026-08-17-proposal-to-evidence-audit.md` with the gap stated as
"exact clean-install ordering on a fresh target still needs a stronger replay".

## What "fresh" means here, precisely

New copy-on-write overlay taken from the unmodified base image
`.vm/disk/ubuntu-26.04-resolute-qual.qcow2`, not reused from any prior run.
Base sha256 identical before and after all boots:

```
a2c089fd5bf33b310057759abb04eb06f72faa10699f109ff416d2a8a300d226  ubuntu-26.04-resolute-qual.qcow2
```

That base image is **not** a pristine Ubuntu install, and the note should not
be read as if it were. Captured from the overlay before anything was changed:

```
OS: Ubuntu 26.04 LTS  (resolute)
installed package count: 1352

ii gdm3 50.1-0ubuntu0.1
ii gnome-session-bin 50.1-0ubuntu0.1
ii gnome-shell 50.1-0ubuntu1.2
ii gnome-shell-common 50.1-0ubuntu1.2
ii gnome-shell-ubuntu-extensions 50.26.04.7ubuntu
ii ubuntu-session 50.1-0ubuntu0.1
ii yaru-theme-gnome-shell 26.04.5.1ubuntu

regolith-session-cosmic          installed 1.2.0-1ubuntu1-1regolith-resolute
regolith-session-common          installed 1.2.0-1ubuntu1-2-1regolith-resolute
regolith-inputd                  installed 0.4.1-2-1regolith-resolute
regolith-displayd                installed 0.3.4-1-1regolith-resolute
cosmolith                        installed 0.1.0-1-1regolith-resolute
cosmic-settings                  installed 1.0.12-1-1regolith-resolute
cosmic-settings-daemon           installed 0.1.0-1-1regolith-resolute
cosmic-session                   installed 1.0.0-1-1regolith-resolute
cosmic-comp                      not-installed
sway-regolith                    installed 1.10-2-1regolith-resolute
greetd                           installed 0.10.3-5

PRESENT /usr/lib/systemd/user/regolith-cosmic.target  owner=regolith-session-cosmic
ABSENT  /usr/lib/systemd/user/regolith-gnome.target
```

So the honest phrasing is: fresh overlay, and — unlike
`05_Testing_Proof/2026-08-17-exact-session-package-qemu-criterion-9.md`, whose
own caveat is "the overlay already contained an earlier tuple" — the earlier
tuple was **purged first**, so the bundle install below is a genuine
newly-installed transaction rather than a version replacement. It is still not
an install onto a stock Ubuntu image.

Prep, before the bundle: purge the GNOME cascade, purge the seven-package
tuple, re-point the display manager at greetd, install `cosmic-comp` (a
`Recommends` of `cosmic-session`, which `--no-install-recommends` does not
pull, and which the installer's own guard requires).

```
purge_exit=0
autoremove_exit=0
tuple_purge_exit=0
regolith-session-cosmic          ABSENT
regolith-session-common          ABSENT
regolith-inputd                  ABSENT
regolith-displayd                ABSENT
cosmolith                        ABSENT
cosmic-settings                  ABSENT
cosmic-settings-daemon           ABSENT
ls: cannot access '/usr/lib/systemd/user/regolith-cosmic.target': No such file or directory
ls: cannot access '/usr/lib/systemd/user/regolith-gnome.target': No such file or directory
ls: cannot access '/usr/share/wayland-sessions/': No such file or directory
Created symlink '/etc/systemd/system/display-manager.service' → '/usr/lib/systemd/system/greetd.service'
dpkg -l | grep -Ei 'gdm3|gnome-shell|gnome-session-bin|ubuntu-session'  ->  gnome_grep_exit=1
cosmiccomp_exit=0 ; cosmic-comp installed 0.1-1-1regolith-resolute
dpkg --audit  ->  audit_exit=0
```

Harness access was provisioned offline against the overlay only, with
`virt-customize --ssh-inject` plus a disposable password; the base disk was
never opened for write. Neither credential was printed at any point.

## Installer identity

`Rahul-2k4/regolith-cosmic-gsoc-proof` `main`, HEAD
`31e23b6e404a24c009893f5d837962fd7cb8eddc` ("fix: verify failed on a correct
COSMIC-only install"), which contains the SIGPIPE fix `3c7ba4d`.

```
218b210e5287663b478b755317a45ea33dee3feaea5a5397b55170334868aac0  scripts/install-real-system.sh
```

identical on the Mac and inside the guest. All 7 bundle debs `OK` against
`mentor-test-2026-08-18.sha256` on the Mac and again in the guest
(`bundle_check_exit=0`).

QEMU invocation used `-device virtio-gpu-pci -display none`, `q35,accel=kvm`,
4 vCPU, 6144 MB, user-mode NAT with an ssh hostfwd.

## Install, through the script, on the purged system

```
PASS: host compatibility
PASS: dependency preflight
PASS: package set validated
check_exit=0
...
The following NEW packages will be installed:
  cosmic-session cosmic-settings cosmic-settings-daemon cosmolith
  regolith-displayd regolith-inputd regolith-session-common
  regolith-session-cosmic
0 upgraded, 8 newly installed, 0 to remove and 53 not upgraded.
PASS: installed exactly 7 packages
install_exit=0
introduced_count=8
```

Eight, not seven, because `cosmic-session` came back as a dependency from the
retained local Resolute pool; the seven bundle debs are the seven the script
counts. Nothing was upgraded over an existing version.

`verify` on this COSMIC-only install, outside a graphical session:

```
PASS: desktop entry: /usr/share/wayland-sessions/regolith-cosmic.desktop
PASS: regolith-cosmic.target unit: /usr/lib/systemd/user/regolith-cosmic.target
PASS: regolith-init-inputd.service unit: /usr/lib/systemd/user/regolith-init-inputd.service
PASS: regolith-init-displayd.service unit: /usr/lib/systemd/user/regolith-init-displayd.service
PASS: regolith-gnome.target absent (GNOME path not installed)
SKIP: runtime checks outside graphical session
verify_exit=0
```

The `31e23b6` fix does what it claims: the stale
`FAIL: regolith-gnome.target unit missing` from
`05_Testing_Proof/2026-08-21-installer-script-end-to-end-qemu.md` is gone and
`verify` exits 0 on a correct COSMIC-only install.

## The mechanism this criterion is actually about

```
# /usr/lib/systemd/user/regolith-cosmic.target
After=cosmic-session.target
PartOf=cosmic-session.target
Wants=regolith-init-inputd.service regolith-init-displayd.service regolith-init-cosmic-idle.service regolith-init-kanshi.service
[Install]
WantedBy=cosmic-session.target

# /usr/lib/systemd/user/regolith-init-inputd.service
[Install]
WantedBy=regolith-gnome.target regolith-cosmic.target
```

The helper services are installed as wanted by **both** session targets — the
install created both wants directories:

```
/etc/systemd/user/regolith-cosmic.target.wants/:  displayd, inputd, kanshi
/etc/systemd/user/regolith-gnome.target.wants/:   displayd, inputd, kanshi
```

so the packaging deliberately does not decide which helpers run. Which target
the session starts decides that, and the launcher starts it explicitly after
importing the desktop identity:

```
266:  systemctl --user import-environment XDG_CURRENT_DESKTOP WAYLAND_DISPLAY SWAYSOCK
269:  if ! systemctl --user start regolith-cosmic.target; then
```

## Blocker found: the shipped launcher aborts on a COSMIC-only system

The first cold-boot COSMIC login on this genuinely COSMIC-only install
**failed**. greetd reported success and the session collapsed inside a second:

```
cosmic-session[2707]: Starting cosmic-session
cosmic-session[2707]: starting process ' COSMIC_SESSION_SOCK=12 /usr/lib/regolith/regolith-session-cosmic-runtime  sway -c /etc/regolith/sway/config'
systemd[2135]: Reached target cosmic-session.target - Cosmic Session Target.
systemd[2135]: Stopping regolith-init-cosmic-idle.service ...
systemd[2135]: Stopping regolith-init-kanshi.service ...
systemd[2135]: Stopped target cosmic-session.target - Cosmic Session Target.
greetd[2255]: pam_unix(greetd:session): session closed for user rahul
```

Post-login state:

```
regolith-cosmic.target is-active: inactive
XDG_CURRENT_DESKTOP: (unset)
loginctl session: Desktop= Type=tty State=active
```

Root cause, in `/usr/lib/regolith/regolith-session-cosmic-runtime` as shipped
by `regolith-session-cosmic 1.2.0-1ubuntu1-2-1regolith-resolute`
(sha256 `8cca2fb4c787d4ffd527a8a8224e25107b4932b3b0444cbd0a1d17346e3db3e5`):
`regolith_legacy_target_is_pre_masked()` switches on
`systemctl --user is-enabled <unit>` and has no arm for `not-found`, so it
falls through to `return 2`. `mask_regolith_legacy_targets_for_cosmic()` then
treats any status other than 1 as fatal and returns 1, and
`regolith_cosmic_runtime_main()` calls
`regolith_cosmic_runtime_abort_session 1`, which stops `cosmic-session.target`
— exactly the teardown in the journal above.

Observed directly in the guest:

```
$ systemctl --user is-enabled regolith-gnome.target
not-found
rc=4
$ systemctl --user is-enabled regolith-wayland.target
not-found
rc=4
$ systemctl --user is-enabled regolith-init-powerd.service
not-found
rc=4
```

All three legacy units are `not-found` precisely because this is a COSMIC-only
install: `regolith-gnome.target` now ships in
`regolith-session-gnome-targets`, and `regolith-wayland.target` /
`regolith-init-powerd.service` come with the legacy Sway path. The launcher
still assumes they exist. Earlier runs never hit this because they either
inherited the units from a prior tuple on the disk or replaced the packaged
runtime with the `6cc2f9f` build.

**Workaround used for the rest of this run**, applied once by hand and clearly
not part of the shipped install:

```
$ systemctl --user mask regolith-gnome.target regolith-wayland.target regolith-init-powerd.service
Unit regolith-gnome.target does not exist, proceeding anyway.
Created symlink '/home/rahul/.config/systemd/user/regolith-gnome.target' → '/dev/null'.
...
regolith-gnome.target        is-enabled=masked
regolith-wayland.target      is-enabled=masked
regolith-init-powerd.service is-enabled=masked
```

`masked` is a case the runtime does handle, so it proceeds. The proper fix is a
`not-found` arm in `regolith_legacy_target_is_pre_masked`, treating an absent
legacy unit the same as a masked one. Not attempted here.

## Cold boots

Four independent cold boots of the one overlay, each a separate `boot_id`,
each a full power-off and power-on rather than a re-login. Every boot starts
from the same pre-login baseline:

```
regolith-cosmic.target is-active: inactive
graphical-session.target is-active: inactive
greetd.service: active
```

### Boot A — COSMIC session, boot_id `a3276af1-cd31-4ced-81ec-89d2a197cbb1`

```
CANCEL_REPLY success / REPLY auth_message / REPLY success / START_REPLY success
SESSION_CMD /usr/bin/regolith-session-cosmic-launch

regolith-cosmic.target is-active: active
  regolith-init-cosmic-idle.service loaded active running
  regolith-init-displayd.service    loaded active running
  regolith-init-inputd.service      loaded active running
  regolith-cosmic.target            loaded active active

regolith-gnome.target: unit file ABSENT; is-active inactive; load-state masked

XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
WAYLAND_DISPLAY=wayland-1
SWAYSOCK=/run/user/1000/sway-ipc.1000.2196.sock
loginctl: Desktop=regolith-cosmic Type=wayland State=active

regolith-init-inputd.service    active
regolith-init-displayd.service  active
systemctl --user --failed  -> 0 loaded units listed.
systemctl --failed         -> 0 loaded units listed.

verify: PASS graphical-session.target active / PASS regolith-cosmic.target active /
        SKIP regolith-gnome.target runtime (unit not installed) /
        PASS regolith-init-inputd.service active / PASS regolith-init-displayd.service active
verify_exit=0

2196 sway -c /etc/regolith/sway/config
2193 /usr/bin/cosmic-session /usr/lib/regolith/regolith-session-cosmic-runtime sway -c /etc/regolith/sway/config
swaymsg -t get_version -> "human_readable": "1.11", get_version_exit=0
dpkg --audit -> audit_exit=0 ; GNOME grep -> gnome_grep_exit=1
```

### Boot B — COSMIC session, boot_id `887da14d-e2dc-4dc7-bc52-eb74b6791721`

Identical result, different PIDs:

```
regolith-cosmic.target is-active: active   (same four units, all running)
regolith-gnome.target: ABSENT / inactive / masked
XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
SWAYSOCK=/run/user/1000/sway-ipc.1000.2204.sock
loginctl: Desktop=regolith-cosmic Type=wayland State=active
inputd active / displayd active / 0 failed user units / 0 failed system units
verify_exit=0
2204 sway ... / 2201 /usr/bin/cosmic-session ...
audit_exit=0 ; gnome_grep_exit=1
```

### Boot C — negative control, plain Sway session, boot_id `00e42e3f-7da9-44eb-9917-28a954f31d1d`

Same overlay, same boot path, same compositor binary and the same
`/etc/regolith/sway/config`. The only thing changed is the session greetd was
asked to start:

```
SESSION_CMD /usr/bin/sway -c /etc/regolith/sway/config
SESSION_ENV XDG_SESSION_DESKTOP=sway XDG_CURRENT_DESKTOP=sway XDG_SESSION_TYPE=wayland
START_REPLY success

regolith-cosmic.target is-active: inactive
  (0 loaded units listed)
regolith-init-inputd.service      inactive
regolith-init-displayd.service    inactive
regolith-init-kanshi.service      inactive
regolith-init-cosmic-idle.service inactive

XDG_CURRENT_DESKTOP=sway
SWAYSOCK=/run/user/1000/sway-ipc.1000.1912.sock
loginctl: Desktop=sway Type=wayland State=active

systemctl --user --failed -> 0 loaded units listed.
verify: SKIP runtime checks outside graphical session ; verify_exit=0
1912 /usr/bin/sway -c /etc/regolith/sway/config    (no cosmic-session process)
```

This is the discriminating result. A compositor came up and a Wayland session
was live, and none of the Regolith COSMIC helpers activated, because the
session identity was not the COSMIC one.

### Boot D — COSMIC session again, boot_id `2cf985ef-cc40-4147-a382-8b4673a58c3f`

```
regolith-cosmic.target is-active: active   (same four units, all running)
regolith-gnome.target: ABSENT / inactive / masked
XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
SWAYSOCK=/run/user/1000/sway-ipc.1000.2191.sock
loginctl: Desktop=regolith-cosmic Type=wayland State=active
inputd active / displayd active / 0 failed user units / 0 failed system units
verify_exit=0
```

Three COSMIC boots, three identical outcomes, and one non-COSMIC boot on the
same disk that produced the opposite outcome. No flapping between boots.

## One deviation worth recording

`regolith-init-kanshi.service` is `inactive` in all three COSMIC boots, where
`05_Testing_Proof/2026-08-21-combined-three-fix-verification-qemu.md` had it
`active`. It is not a failure — it ran and exited on a TERM during the session
handover:

```
Active: inactive (dead) ... Duration: 140ms
Process: 2225 ExecStart=/usr/bin/kanshi -c /home/rahul/.config/regolith3/kanshi/config (code=killed, signal=TERM)
Result=success ; ExecMainStatus=15
```

`regolith-cosmic.target` `Wants=` it rather than `Requires=` it, so the target
stays active and the failed-unit sweep stays empty. Unexplained, and left open.

## Verdict on Criterion 3

The ordering question itself now has the evidence it was missing: on one disk,
with one package set and one boot path, the COSMIC session activates
`regolith-cosmic.target` and its helpers on three separate cold boots, a
non-COSMIC session on the same disk activates none of them, and the packaging
gives both session targets equal claim on the helpers so the outcome is not an
artifact of what was installed. That is gating by session identity, not by
install order or coincidence.

It does not justify moving Criterion 3 to `Met` yet, for one reason that is
not about ordering at all: **the shipped launcher will not start a COSMIC
session on a COSMIC-only install.** Three of the four boots only reached a
COSMIC session because of a hand-applied mask of three absent legacy units. A
criterion phrased as "cold-login ordering is gated by session identity" cannot
be called met while the shipped cold login aborts on the very configuration
the criterion is about.

Suggested wording: keep `Partial`, and replace the old gap text ("exact
clean-install ordering on a fresh target still needs a stronger replay") with
the new one — ordering is demonstrated across three cold boots plus a negative
control on a purged fresh overlay; the remaining gap is the
`regolith_legacy_target_is_pre_masked` `not-found` defect. It becomes a
one-line code fix plus a re-run rather than an open research question.

What this does **not** prove, in any reading:

- QEMU only, headless (`-display none`). No hardware, no enabled output, no
  pixels. Both outputs report `active=False` under `-display none`, as in the
  earlier notes.
- Not a stock-Ubuntu clean install. The base image already carried the GNOME
  cascade and an older tuple; both were purged first, which is stronger than
  the 2026-08-17 run but is not the same as installing onto a stock image.
- Not an archive install: the bundle is local debs plus a retained local
  Resolute pool, unsigned, not published.
- Login was driven over the greetd IPC socket, not through a greeter UI.
- One user, one seat, one output.

## Cleanup

VM powered off cleanly on every boot after the first (boot 1's `poweroff`
stalled with the known `systemd-journald: Failed to send WATCHDOG=1` symptom
and was resolved with sysrq `s` + `u`; `qemu-img check` reported
`No errors were found on the image.`). Overlay deleted, cloned proof repo
deleted, disposable keypair and password file shredded and removed, and the
guest-side password copy shredded after each login before any check ran.
Neither credential was printed at any point. Base disk sha256 reconfirmed
unchanged after the run.
