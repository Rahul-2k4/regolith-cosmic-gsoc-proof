# Combined three-fix verification boot — GPU + inputd XDG env + `--no-install-recommends`, one QEMU boot

Date: 2026-08-21 (IST) / 2026-08-20 18:52 UTC (guest boot timestamp)
Kind: **QEMU proof.** Nothing here was run on real hardware.

## Why this run exists

`09_Final_Docs/2026-08-20-gnome-survivor-removal-plan.md` closes with one
remaining step before Criterion 2 ("Session boots with zero GNOME
session/bootstrap packages") can move from `Partial` to `Met`: a single
clean boot exercising all three of the 2026-08-19 fixes together, since
each had only ever been verified separately.

The three fixes:

1. QEMU `-device virtio-gpu-pci` (GPU/DRM/EGL plumbing)
   — `05_Testing_Proof/2026-08-19-ubuntu-2604-resolute-gpu-fix-new-blocker.md`
2. `regolith-inputd` `XDG_CURRENT_DESKTOP` env-import fix, commit `6cc2f9f`
   on `rahul/regolith-session-inputd-xdg-env-20260819`
   — `05_Testing_Proof/2026-08-19-regolith-inputd-xdg-env-fix-graphical-login.md`
3. Mentor bundle installed with `--no-install-recommends`, commit `eb385d0`
   on `rahul/mentor-real-system-installer-20260818`
   — `05_Testing_Proof/2026-08-19-mentor-bundle-no-install-recommends-followup.md`

## Setup

Copy-on-write overlay over `.vm/disk/ubuntu-26.04-resolute-qual.qcow2`.
The base disk was never opened for write; sha256 confirmed identical before,
mid-run and after:

```
a2c089fd5bf33b310057759abb04eb06f72faa10699f109ff416d2a8a300d226  ubuntu-26.04-resolute-qual.qcow2
```

Bundle integrity checked three times — on the Mac, on the host after
transfer, and inside the guest — all 7 packages `OK` against
`mentor-test-2026-08-18.sha256`.

Two boots of the same overlay:

- **Boot 1 (prep)** — bring the disk to the state the three fixes describe.
- **Boot 2 (verification)** — fresh boot, greetd login, all nine health
  checks. Every check below is from boot 2, boot_id
  `9d1276a1-9a9c-4a8c-a2c5-82a5f0be9ff9`, one boot, one login.

Verification-boot QEMU invocation, verbatim:

```
qemu-system-x86_64 -name combined-verify-20260821 -machine q35,accel=kvm \
  -cpu host -smp 4 -m 6144 -rtc base=localtime \
  -device virtio-gpu-pci -display none \
  -device qemu-xhci -device usb-tablet \
  -nic user,model=virtio-net-pci,hostfwd=tcp:127.0.0.1:2223-:22 \
  -drive if=virtio,format=qcow2,file=<overlay>.qcow2 \
  -monitor unix:<scratch>/mon.sock,server,nowait \
  -serial file:<scratch>/logs/serial-boot2.log -daemonize
```

## Boot 1 — prep, and what went wrong on the way

### The GNOME cascade would not purge on the first try

The base disk carries the ~300-package GNOME cascade from the 2026-08-18
plain `apt-get install -y` run. The first purge attempt died:

```
Removing gdm3 (50.1-0ubuntu0.1)...
Failed to stop gdm3.service: Unit gdm.service not loaded.
invoke-rc.d: initscript gdm3, action "stop" failed.
dpkg: error processing package gdm3 (--remove):
 old gdm3 package prerm maintainer script subprocess failed with exit status 5
dpkg: too many errors, stopping
purge_exit=100
```

Same class of gdm3-packaging misbehaviour already recorded on 2026-08-19: it
also left `/etc/systemd/system/display-manager.service` re-pointed at
`gdm3.service`, and `systemctl enable greetd.service` then refused with
`File '/etc/systemd/system/display-manager.service' already exists`.

Fixed by a temporary `policy-rc.d` returning 101 so `invoke-rc.d` does not
try to touch units mid-purge, then removing the stale alias symlink before
re-enabling greetd. Second attempt:

```
purge_exit=0
autoremove_exit=0
Created symlink '/etc/systemd/system/display-manager.service' -> '/usr/lib/systemd/system/greetd.service'
dpkg -l | grep -Ei 'gdm3|gnome-shell|gnome-session-bin|ubuntu-session'  ->  gnome_grep_exit=1  (no matches)
dpkg --audit  ->  audit_exit=0
```

Whole regolith/cosmic tuple survived the purge intact.

### The mentor installer script aborts before it can install anything — new bug

`scripts/install-real-system.sh` (branch `rahul/mentor-real-system-installer-20260818`,
HEAD `0380836`, which contains `eb385d0`) fails its own preflight on this
guest, on a *different* dependency each time:

```
run 1: PASS: host compatibility / FAIL: no apt candidate for dependency: cosmic-session   check_exit=1
run 2: PASS: host compatibility / FAIL: no apt candidate for dependency:  dbus            check_exit=1
```

Every one of those dependencies genuinely resolves:

```
cosmic-session               Candidate:1.0.0-1-1regolith-resolute
dbus                         Candidate:1.16.2-2ubuntu4
regolith-displayd            Candidate:0.3.4-1-1regolith-resolute
... (all 15 Depends of the bundle's regolith-session-cosmic have candidates)
```

Root cause, reproduced 40/40: `dependency_available()` runs
`apt-cache policy "$dependency" | grep -Eq 'Candidate:[[:space:]]+[^()]'`
under the script's own `set -Eeuo pipefail`. `grep -q` exits the moment it
matches on line 3, `apt-cache policy` keeps writing the version table, takes
SIGPIPE, and `pipefail` promotes that to a pipeline failure — so a
*successful* match is read as "no candidate":

```
( set -o pipefail; apt-cache policy dbus | grep -Eq "Candidate:[[:space:]]+[^()]" )
pipeline_rc=141          # 128 + 13 = SIGPIPE
apt-cache alone rc=0
grep alone rc=0

with    pipefail: 40/40 spurious failures
without pipefail:  0/40 failures
```

This is a real, live regression in the mentor-facing installer: as it
stands, `install-real-system.sh check` and `install` cannot succeed on a
real system. It was not caught earlier because `eb385d0` was validated by a
contract test, not by a live installer run — the 2026-08-19
`--no-install-recommends` proof invoked `apt-get` directly, never the
script.

Two further preflight facts found on the way:

- `check_cosmic_comp_present()` (added in `0380836`) correctly fired: this
  disk had no `cosmic-comp`, because its base install already used
  `apt-get install -y --no-install-recommends regolith-session-cosmic` and
  `cosmic-comp` is a `Recommends` of `cosmic-session`. Satisfied by
  installing `cosmic-comp 0.1-1-1regolith-resolute` from the local pool, as
  the guard's own error text instructs.
- `sway` is *not* at risk from `--no-install-recommends`: `/usr/bin/sway`
  belongs to `sway-regolith`, a hard `Depends` of `regolith-session-cosmic`.

### What was installed instead

Because the script aborts before line 261, the install was performed with
that line's command verbatim:

```
apt-get install -y --no-install-recommends <7 bundle debs>
...
Unpacking regolith-session-cosmic (1.2.0-1ubuntu1-2-1regolith-resolute) over (1.2.0-1ubuntu1-1regolith-resolute)...
install_exit=0
introduced_count=0
```

**Zero new packages introduced.** No GNOME cascade returned. `dpkg --audit`
exit 0.

The inputd fix was then applied on top of the freshly installed package
(the `.deb` ships its own copy of the runtime script, so patch order
matters):

```
packaged version sha: 8cca2fb4c787d4ffd527a8a8224e25107b4932b3b0444cbd0a1d17346e3db3e5
patched  version sha: 2832066d65280c9959f79558943bfb2ff21f749078945091af0099d29745435d   (= commit 6cc2f9f)

34:  systemctl --user unset-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP || true
108: if ! systemctl --user import-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP; then
```

### Boot-1 shutdown hung

`system_powerdown` and then `systemctl poweroff` both stalled after systemd
had stopped its services; the guest sat for >10 minutes emitting
`systemd-journald: Failed to send WATCHDOG=1 notification message`. Resolved
with sysrq `s` (Emergency Sync) + `u` (Emergency Remount R/O) before
stopping QEMU. `qemu-img check` on the overlay afterwards: `No errors were
found on the image.` Cause not investigated; plausibly related to the
autoremove that purged `systemd-oomd`. Flagged, not chased.

## Boot 2 — the verification boot

```
Startup finished in 680ms (kernel) + 2.834s (initrd) + 2.843s (userspace) = 6.359s
graphical.target reached after 2.842s in userspace.
```

greetd IPC login (same client as every prior proof in this project):

```
CANCEL_REPLY success
REPLY auth_message
REPLY success
START_REPLY success
login_client_exit=0
```

### Check 0 — the inputd fix, directly observed

```
$ systemctl --user show-environment | grep -E 'XDG_CURRENT_DESKTOP|WAYLAND_DISPLAY|SWAYSOCK'
SWAYSOCK=/run/user/1000/sway-ipc.1000.2255.sock
WAYLAND_DISPLAY=wayland-1
XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
```

### Check 1 — `regolith-init-inputd.service`  PASS

```
● regolith-init-inputd.service - Start Regolith Input Daemon
     Loaded: loaded (/usr/lib/systemd/user/regolith-init-inputd.service; enabled; preset: enabled)
     Active: active (running) since Thu 2026-08-20 18:52:41 UTC; 50s ago
   Main PID: 2335 (regolith-inputd)
is-active: active
```

No trace of the old `GNOME input backend selected, but regolith-inputd was
built without the gnome feature` error.

### Check 2 — failed user units  PASS

```
$ systemctl --user --failed
  UNIT LOAD ACTIVE SUB DESCRIPTION
0 loaded units listed.
```

Note this is strictly better than the 2026-08-19 runs: `nm-applet` and
`org.gnome.Evolution-alarm-notify`, which used to fail with `cannot open
display:`, are both `active running` here.

### Check 3 — `regolith-cosmic.target`  PASS

```
is-active: active

  regolith-init-cosmic-idle.service loaded active running Regolith COSMIC idle and lock fallback
  regolith-init-displayd.service    loaded active running Start Regolith Display Daemon
  regolith-init-inputd.service      loaded active running Start Regolith Input Daemon
  regolith-init-kanshi.service      loaded active running Start Kanshi for Regolith
  regolith-cosmic.target            loaded active active  Regolith COSMIC session helpers
```

### Check 4 — live compositor and IPC  PASS, with one caveat

```
$ pgrep -a sway
2255 sway -c /etc/regolith/sway/config
2279 swaybg
2333 swayidle -w timeout 300 gtklock

$ pgrep -a cosmic
2252 /usr/bin/cosmic-session /usr/lib/regolith/regolith-session-cosmic-runtime sway -c /etc/regolith/sway/config

$ swaymsg -t get_version
{ "human_readable": "1.11", "variant": "sway",
  "loaded_config_file_name": "/etc/regolith/sway/config" }
get_version_exit=0

$ swaymsg -t get_outputs      # get_outputs_exit=0
$ swaymsg -t get_workspaces   # [] , get_workspaces_exit=0
```

**Caveat, stated plainly:** both outputs come back inactive —

```
Virtual-1 Red Hat, Inc. QEMU Monitor active=False {'x':0,'y':0,'width':0,'height':0}
Virtual-2 Red Hat, Inc. QEMU Monitor active=False {'x':0,'y':0,'width':0,'height':0}
```

and the HMP `screendump` taken while the session was live
(`logs/session-20260821.png`) shows the text console, not a rendered
desktop. Under `-display none` no output ever gets enabled. So this run
proves a healthy compositor process with a working IPC surface; it does
**not** prove pixels on a screen. Prior runs used the same flags and are
subject to the same limit.

### Check 5 — GNOME session/bootstrap packages  PASS

```
$ dpkg -l | grep -Ei 'gdm3|gnome-shell|gnome-session-bin|ubuntu-session'
grep_exit=1        # no matches
```

Everything still carrying a `gnome` name, and nothing else:

```
gnome-icon-theme 3.12.0-7
gnome-keyring 50.0-1
gnome-themes-extra:amd64 3.28-5
gnome-themes-extra-data 3.28-5
```

`gnome-keyring` and `gnome-themes-extra(-data)` are the survivors already
dispositioned as hard `Depends` in the removal plan. `gnome-icon-theme` is a
theme asset, not session or bootstrap machinery. `dconf-service` and
`dconf-gsettings-backend` remain installed as previously justified.

### Check 6 — `dpkg --audit`  PASS

```
audit_exit=0        # no output
```

### Check 7 — render nodes  PASS

```
crw-rw----+1 root render 226, 128 renderD128
crw-rw----+1 root render 226, 129 renderD129
```

### Check 8 — prior EGL/DRI2/GBM crash text  PASS, absent

```
$ journalctl -b | grep -iE 'EGL|DRI2|gbm_bo_create|Permission denied|DRM_IOCTL'
system_journal_grep_exit=1     # none found
$ journalctl --user -b | grep -iE 'EGL|DRI2|gbm_bo_create|Permission denied|DRM_IOCTL'
user_journal_grep_exit=1       # none found
```

### Check 9 — compositor exit-code-1 signature  PASS, absent

Counted over the whole of both journals for this boot (1744 system lines,
262 user lines):

```
exited with error code   system=0 user=0
failed with code         system=0 user=0
restarted process        system=0 user=0
status=1/FAILURE         system=0 user=0
status=137               system=0 user=0
signal=KILL              system=0 user=0
core-dump                system=0 user=0
cosmic-comp              system=0 user=0
```

The entire cosmic-session story for this boot is three lines, no restarts:

```
cosmic-session[2252]: Starting cosmic-session
cosmic-session[2252]: starting process ' COSMIC_SESSION_SOCK=12 /usr/lib/regolith/regolith-session-cosmic-runtime  sway -c /etc/regolith/sway/config'
systemd[1601]: Reached target cosmic-session.target - Cosmic Session Target.
```

### Stability re-check at ~6 minutes uptime

```
up 6 minutes
inputd: active
cosmic.target: active
failed units: 0 loaded units listed.
2255 sway / 2279 swaybg / 2333 swayidle   (all still alive)
swaymsg -t get_version -> ipc_exit=0
```

## Verdict

All nine checks pass on one boot with all three fixes in place. On the
narrow question the removal plan poses — does the session come up with zero
GNOME session/bootstrap packages — the answer here is yes, and it is
directly observed rather than inferred.

Two honest bounds on the claim:

1. **QEMU only, and headless.** No hardware. No enabled output, so no
   rendered desktop was demonstrated — only a live compositor with a working
   IPC surface.
2. **The mentor installer script did not run.** The `--no-install-recommends`
   *flag* is verified (install exit 0, zero packages introduced, no cascade).
   The *script that carries it* aborts in preflight on a SIGPIPE/`pipefail`
   bug, documented above. Anyone told to run `install-real-system.sh` today
   would hit that, which is a live problem independent of Criterion 2.

Also observed, not investigated: the greetd session prints
`Error: NameTaken` once and `Error: No default value provided` eight times
to the console at launch. Neither string appears in journald. Pre-existing
console noise; flagged only.

## Cleanup

QEMU stopped; overlay deleted; the disposable ed25519 keypair and password
file shredded and their scratch directory removed. Neither credential was
printed at any point. Base disk sha256 reconfirmed unchanged after the run.
