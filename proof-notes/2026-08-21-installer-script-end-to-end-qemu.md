# Combined three-fix verification, run through the mentor installer script

Date: 2026-08-21 (IST) / 2026-08-21 03:29-03:41 UTC (guest timestamps)
Kind: **QEMU proof.** Nothing here was run on real hardware.

## Why this run exists

The 2026-08-21 combined three-fix verification passed all nine health checks,
but it could not use `scripts/install-real-system.sh`: the script aborted in
preflight with a spurious "no apt candidate for dependency" on a different
dependency each run. That install was performed with the script's own inner
`apt-get` line verbatim, so the `--no-install-recommends` *flag* was proven and
the *script* was not.

The SIGPIPE/`pipefail` root cause is fixed on `main` at `3c7ba4d`
("fix: installer preflight aborted on a successful dependency match"). This run
repeats the same verification, changing exactly one thing: the install is
driven by the script.

## Setup

- Installer commit under test: `3c7ba4d6d8f5cdc1729308f60b88356bd9b69772`
  (tip of `origin/main`), staged from a `git archive` of that commit.
  `sha256(scripts/install-real-system.sh) = 1cb9b61a9abbc57bcc86ff2cad56ce3c41f3f6f77f46b80e11f2bda2f9ecf595`,
  identical on the Mac, on the host after transfer, and inside the guest.
- Copy-on-write overlay over `.vm/disk/ubuntu-26.04-resolute-qual.qcow2`.
  Base sha256 identical before and after the run:
  `a2c089fd5bf33b310057759abb04eb06f72faa10699f109ff416d2a8a300d226`
- All 7 bundle debs verified `OK` against `mentor-test-2026-08-18.sha256` on
  the host and again inside the guest.
- QEMU invocation identical to the prior run except the VM name and the
  hostfwd port, and still `-device virtio-gpu-pci -display none`.

Two boots of one overlay: boot 1 = prep + install, boot 2 = greetd login and
the nine checks. Boot 2 boot_id `9fc69a6d-4195-4602-8145-36e559bf4722`.

## Boot 1

### Prep

The GNOME cascade purge succeeded on the first attempt this time, because the
`policy-rc.d` guard from the prior run was installed up front rather than after
a failure:

```
purge_exit=0
autoremove_exit=0
Created symlink /etc/systemd/system/display-manager.service -> /usr/lib/systemd/system/greetd.service
dpkg -l | grep -Ei gdm3|gnome-shell|gnome-session-bin|ubuntu-session  ->  gnome_grep_exit=1
dpkg --audit  ->  audit_exit=0
```

### One staging defect the script caught, correctly

The first `check` failed because the tar transfer from macOS carried
AppleDouble sidecar files into the bundle directory:

```
PASS: host compatibility
FAIL: package set differs from manifest: unexpected ._cosmic-settings_1.0.12-1-1regolith-resolute_amd64.deb
check0_exit=1
```

That is the manifest guard working as designed, not a script bug. The `._*`
files were deleted and the seven-deb manifest re-verified `OK` in the guest.

### The bug under test: dependency preflight

Three consecutive `check` runs, cosmic-comp still absent:

```
===== check run 1/2/3 (cosmic-comp absent) =====
PASS: host compatibility
PASS: dependency preflight
FAIL: cosmic-comp is not installed. ...
check_exit=1
```

`PASS: dependency preflight` 3/3. The spurious "no apt candidate" abort is
gone. What stops the run now is the legitimate `check_cosmic_comp_present`
guard added in `0380836`, firing for the documented reason: this disk was
built with `--no-install-recommends`, and `cosmic-comp` is a `Recommends` of
`cosmic-session`.

Prerequisite satisfied as the guard's own error text instructs:

```
apt-get install -y --no-install-recommends cosmic-comp   ->  cosmiccomp_exit=0
cosmic-comp 0.1-1-1regolith-resolute
```

Three more `check` runs:

```
===== check run 1/2/3 (prereqs satisfied) =====
PASS: host compatibility
PASS: dependency preflight
PASS: package set validated
check_exit=0
```

The regression test shipped with the fix, run inside the same guest:

```
PASS: dbus resolved
PASS: cosmic-session resolved
PASS: libc6 resolved
all dependencies resolved, no SIGPIPE regression
sigpipe_test_exit=0
```

### Install phase, through the script

```
$ /opt/cv/stage/scripts/install-real-system.sh install --package-dir <bundle>
PASS: host compatibility
PASS: dependency preflight
PASS: package set validated
BASELINE: /var/lib/regolith-cosmic-gsoc/20260821T032945Z
...
1 upgraded, 0 newly installed, 0 to remove and 53 not upgraded.
Unpacking regolith-session-cosmic (1.2.0-1ubuntu1-2-1regolith-resolute) over (1.2.0-1ubuntu1-1regolith-resolute)...
PASS: installed exactly 7 packages
install_exit=0

introduced_count=0
dpkg --audit  ->  audit_exit=0
dpkg -l | grep -Ei gdm3|gnome-shell|gnome-session-bin|ubuntu-session  ->  gnome_grep_exit=1
```

Zero new packages introduced, same as the prior hand-run install.

### One new finding: the script's own `verify` phase fails

```
$ /opt/cv/stage/scripts/install-real-system.sh verify --package-dir <bundle>
PASS: desktop entry: /usr/share/wayland-sessions/regolith-cosmic.desktop
PASS: regolith-cosmic.target unit: /usr/lib/systemd/user/regolith-cosmic.target
FAIL: regolith-gnome.target unit missing: /usr/lib/systemd/user/regolith-gnome.target
PASS: regolith-init-inputd.service unit: /usr/lib/systemd/user/regolith-init-inputd.service
PASS: regolith-init-displayd.service unit: /usr/lib/systemd/user/regolith-init-displayd.service
SKIP: runtime checks outside graphical session
verify_exit=1
```

`regolith-gnome.target` moved from `regolith-session-cosmic` to
`regolith-session-common` (regolith-session commit b12b837, "fix(debian): move
regolith-gnome.target to session-common for flashback path"). The installer's
`verify` still looks for it under the cosmic package's payload. Not chased
here; `install` is unaffected. Flagged as the next installer defect.

### inputd fix re-applied on top of the freshly installed package

```
sha256 /usr/lib/regolith/regolith-session-cosmic-runtime
  = 2832066d65280c9959f79558943bfb2ff21f749078945091af0099d29745435d   (= commit 6cc2f9f)
34:  systemctl --user unset-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP || true
108: if ! systemctl --user import-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP; then
```

### Boot-1 shutdown hung again

`systemctl poweroff` stalled past 120s with
`systemd-journald: Failed to send WATCHDOG=1 notification message`, exactly the
prior run's symptom. Resolved with sysrq `s` + `u`. `qemu-img check`:
`No errors were found on the image.` Boot 2 powered off cleanly on its own
(`reboot: Power down` in the serial log), so the hang is not persistent.

## Boot 2 — verification boot

```
Startup finished in 520ms (kernel) + 2.150s (initrd) + 3.043s (userspace) = 5.713s
graphical.target reached after 3.041s in userspace.
```

greetd IPC login:

```
CANCEL_REPLY success
REPLY auth_message
REPLY success
START_REPLY success
login_client_exit=0
```

### Check 0 — inputd env fix, directly observed

```
SWAYSOCK=/run/user/1000/sway-ipc.1000.2577.sock
WAYLAND_DISPLAY=wayland-1
XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
```

### Check 1 — `regolith-init-inputd.service`  PASS

```
Active: active (running) since Fri 2026-08-21 03:34:30 UTC; 48s ago
Main PID: 2657 (regolith-inputd)
is-active: active
```

### Check 2 — failed user units  PASS

```
0 loaded units listed.
```

### Check 3 — `regolith-cosmic.target`  PASS

```
is-active: active
  regolith-init-cosmic-idle.service loaded active running
  regolith-init-displayd.service    loaded active running
  regolith-init-inputd.service      loaded active running
  regolith-init-kanshi.service      loaded active running
  regolith-cosmic.target            loaded active active
```

### Check 4 — live compositor and IPC  PASS, same caveat as before

```
2577 sway -c /etc/regolith/sway/config
2604 swaybg
2655 swayidle -w timeout 300 gtklock
2574 /usr/bin/cosmic-session /usr/lib/regolith/regolith-session-cosmic-runtime sway -c /etc/regolith/sway/config

swaymsg -t get_version   -> "human_readable": "1.11", loaded_config_file_name /etc/regolith/sway/config, get_version_exit=0
swaymsg -t get_outputs   -> get_outputs_exit=0
swaymsg -t get_workspaces-> get_workspaces_exit=0
```

Caveat unchanged: both outputs report `active=False` with a 0x0 rect under
`-display none`, so this proves a healthy compositor with a working IPC
surface, not pixels on a screen.

### Check 5 — GNOME session/bootstrap packages  PASS

```
grep_exit=1        # no matches
```

Remaining gnome-named packages, unchanged from the prior run:
`gnome-icon-theme 3.12.0-7`, `gnome-keyring 50.0-1`,
`gnome-themes-extra:amd64 3.28-5`, `gnome-themes-extra-data 3.28-5`.

### Check 6 — `dpkg --audit`  PASS

```
audit_exit=0
```

### Check 7 — render nodes  PASS

```
crw-rw----+1 root render 226, 128 renderD128
crw-rw----+1 root render 226, 129 renderD129
```

### Check 8 — EGL/DRI2/GBM crash text  PASS, absent

```
system_journal_grep_exit=1
user_journal_grep_exit=1
```

### Check 9 — compositor exit-1 signature  PASS, absent

```
crashgrep_exit=1
```

cosmic-session, whole story for the boot, no restarts:

```
cosmic-session[2574]: Starting cosmic-session
cosmic-session[2574]: starting process  COSMIC_SESSION_SOCK=12 /usr/lib/regolith/regolith-session-cosmic-runtime sway -c /etc/regolith/sway/config
systemd[1936]: Reached target cosmic-session.target - Cosmic Session Target.
```

### Stability re-check at ~7 minutes

```
up 7 minutes
inputd: active
cosmic.target: active
failed units: 0 loaded units listed.
2577 sway / 2604 swaybg / 2655 swayidle
swaymsg -t get_version -> ipc_exit=0
dpkg --audit -> audit_exit=0
```

## Verdict

`install-real-system.sh` now runs end to end on this guest: `check` exit 0
(3/3), `install` exit 0, seven packages installed, zero packages introduced,
`dpkg --audit` clean, and the resulting session passes all nine post-boot
health checks. The gap the prior note left open — script proven, not just the
flag — is closed for `check` and `install`.

Two bounds stay honest:

1. QEMU only, and headless. No hardware, no enabled output.
2. The script's `verify` subcommand still exits 1, on a stale expectation that
   `regolith-gnome.target` ships in `regolith-session-cosmic`. Separate defect,
   filed above, not fixed here.

## Cleanup

QEMU stopped; overlay deleted; the disposable ed25519 keypair and password file
shredded and removed, and the guest-side password copy shredded before the
checks ran. Neither credential was printed at any point. Base disk sha256
reconfirmed unchanged after the run.
