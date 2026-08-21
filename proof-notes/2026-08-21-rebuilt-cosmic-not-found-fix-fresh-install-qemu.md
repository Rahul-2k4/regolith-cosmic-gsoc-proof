# Rebuilt regolith-session-cosmic: fresh COSMIC-only install reaches a real login, three cold boots, no hand workaround

Date: 2026-08-21 (IST) / guest boots 2026-08-21 14:08-14:20 UTC
Kind: **QEMU proof.** Nothing here ran on real hardware. Guest ran headless
(`-display none`), so no check below is a claim about pixels.

Follow-up to `08_Blockers/2026-08-21-cosmic-session-launcher-abort-on-not-found-legacy-target.md`
and `05_Testing_Proof/2026-08-21-criterion-3-fresh-install-ordering-qemu.md`.

## Lineage defect found before the build (read this first)

The blocker note states the fix branch is based on
`codex/session-target-ownership-20260818`, "the branch whose runtime script
matches the shipped package". Measured, that is wrong:

```
sha256 usr/lib/regolith/regolith-session-cosmic-runtime, per branch
  rahul/session-common-version-fix-20260818      8cca2fb4c787d4ffd527a8a8224e25107b4932b3b0444cbd0a1d17346e3db3e5
  codex/session-target-ownership-20260818        a3331e4fa2ef29c9f6fb8603030f451288dff81f2ba08c4efb792f970bef5cd4
  rahul/cosmic-runtime-not-found-legacy-target-20260821  67b7d022986b1e75d5883014bdc58717c7689eba8df3fdce55c53b3196bea22e
```

`8cca2fb4...` is the hash the blocker note itself records for the script
extracted from the shipped `1.2.0-1ubuntu1-2-1regolith-resolute` deb. So the
shipped `-2` runtime comes from `rahul/session-common-version-fix-20260818`,
not from the branch PR #2 is based on. `git merge-base --is-ancestor b6c4478
fd876a8` returns false.

Consequence: this rebuild is **not** "the shipped package plus a `not-found`
arm". Diffing the shipped lineage against the fix branch:

```
$ git diff rahul/session-common-version-fix-20260818..rahul/cosmic-runtime-not-found-legacy-target-20260821 --stat
 debian/changelog                                   |   7 -
 debian/control                                     |  14 +-
 debian/regolith-session-common.install             |   2 +
 debian/regolith-session-gnome-targets.install      |   2 -
 debian/rules                                       |   1 +
 tests/...                                          | ...
 usr/lib/regolith/regolith-session-cosmic-runtime   |  85 +-----------
 usr/lib/systemd/user/regolith-cosmic.target        |   2 +-
 15 files changed, 83 insertions(+), 411 deletions(-)
```

Among the 85 changed runtime lines, the fix branch **drops** the
`regolith_cosmic_runtime_terminate_owned_parent` teardown block that ships in
`-2`, and it no longer builds a `regolith-session-gnome-targets` binary
(that content moved into `regolith-session-common` on the fix branch).

The build below was run as instructed, from the fix branch. It proves the
`not-found` fix; it does not prove that the fix branch is a safe successor to
the shipped `-2`. **Recommendation: rebase PR #2 onto
`rahul/session-common-version-fix-20260818` and re-run this exact harness.**

## Package build

Build branch: `Rahul-2k4/regolith-session`
`rahul/cosmic-runtime-not-found-legacy-target-20260821-build3`, commit
`772a755bf68301038f8c7a5ff99fa98c5ce08ff1` = fix-branch tip `fd876a8` plus one
`debian/changelog` entry and nothing else.

Version chosen: `1.2.0-1ubuntu1-3-1regolith-resolute` — the next step in the
same scheme the mentor bundle used (`-2-1regolith-resolute`), and it sorts
above it.

Built through the normal Voulage local path on the laptop:

```
$ .github/scripts/local-build.sh \
    --extension <voulage>/.github/scripts/ext-debian.sh \
    --git-repo-path <voulage> \
    --package-name regolith-session \
    --package-url https://github.com/Rahul-2k4/regolith-session.git \
    --package-ref rahul/cosmic-runtime-not-found-legacy-target-20260821-build3 \
    --distro ubuntu --codename resolute --stage unstable
BUILD_RC=0
dpkg-deb: building package 'regolith-session-cosmic' in
  '../regolith-session-cosmic_1.2.0-1ubuntu1-3-1regolith-resolute_amd64.deb'.
```

`debian/rules` runs the new regression test on every build, so
`tests/regolith-cosmic-runtime-not-found-legacy-target.sh` passed as part of
`BUILD_RC=0`.

Lintian was unchanged from prior builds of this source (one pre-existing
`E: regolith-session-flashback: depends-on-metapackage Depends: xorg`, plus
`no-manual-page` / `package-has-long-file-name` warnings). Nothing new.

```
sha256(regolith-session-cosmic_1.2.0-1ubuntu1-3-1regolith-resolute_amd64.deb)
  = ce5ac906aeba92f9f0ac464f29cbfa9a4290dddbbf5ac4b1e3d5e5f6a2d001ab
```

## The deb really carries the fix (byte-for-byte, not a version string)

```
$ dpkg-deb -x <deb> /tmp/deb3x
$ git show rahul/cosmic-runtime-not-found-legacy-target-20260821:usr/lib/regolith/regolith-session-cosmic-runtime > /tmp/src-runtime
$ cmp /tmp/src-runtime /tmp/deb3x/usr/lib/regolith/regolith-session-cosmic-runtime
RUNTIME_BYTE_IDENTICAL_TO_FIX_BRANCH=yes
67b7d022986b1e75d5883014bdc58717c7689eba8df3fdce55c53b3196bea22e  /tmp/src-runtime
67b7d022986b1e75d5883014bdc58717c7689eba8df3fdce55c53b3196bea22e  /tmp/deb3x/usr/lib/regolith/regolith-session-cosmic-runtime
```

`Depends:` on `regolith-session-common` is unversioned, so pairing the `-3`
cosmic deb with the bundle's `-2` common deb is a legal install.

## Guest setup

New copy-on-write overlay off the unmodified base
`.vm/disk/ubuntu-26.04-resolute-qual.qcow2`, not reused from any prior run.
Base sha256 identical before and after every boot:

```
a2c089fd5bf33b310057759abb04eb06f72faa10699f109ff416d2a8a300d226
```

Overlay state as inherited (same as the 2026-08-21 Criterion 3 run): the base
carries the GNOME cascade and an older tuple, including
`regolith-session-cosmic 1.2.0-1ubuntu1-1regolith-resolute`. Both were purged
before the bundle install, so this is a genuine new install rather than a
version bump:

```
purge_exit=0 ; autoremove_exit=0 ; tuple_purge_exit=0
regolith-session-cosmic / -common / regolith-inputd / regolith-displayd /
cosmolith / cosmic-settings / cosmic-settings-daemon   ->  all ABSENT
ls: cannot access '/usr/lib/systemd/user/regolith-cosmic.target'
ls: cannot access '/usr/lib/systemd/user/regolith-gnome.target'
ls: cannot access '/usr/share/wayland-sessions/'
display-manager.service -> /usr/lib/systemd/system/greetd.service
cosmiccomp_exit=0 ; cosmic-comp 0.1-1-1regolith-resolute
dpkg --audit -> audit_exit=0 ; GNOME grep -> gnome_grep_exit=1
```

A `policy-rc.d` `exit 101` guard was used only for the purge and was removed
before the bundle install, so the install itself was unguarded.

Harness access was provisioned offline against the overlay only
(`virt-customize --ssh-inject` plus a disposable password). The base disk was
never opened for write. Neither credential was printed at any point.

## Installer and bundle identity

`Rahul-2k4/regolith-cosmic-gsoc-proof` `main`, HEAD `31e23b6` ("fix: verify
failed on a correct COSMIC-only install"), which contains the SIGPIPE fix
`3c7ba4d`.

```
218b210e5287663b478b755317a45ea33dee3feaea5a5397b55170334868aac0  scripts/install-real-system.sh
```

identical on the laptop and inside the guest, before and after staging.

**Staged bundle deviation, disclosed:** the six other bundle debs are the
unmodified committed artifacts. `regolith-session-cosmic_-2-...deb` was
replaced by the rebuilt `-3` deb, and the two corresponding lines in the
staged copy of `artifacts/mentor-test-2026-08-18.sha256` were updated to the
new filename and hash. `git diff --stat` on the staged clone shows exactly
those two changes and nothing else. All seven debs verified `OK` against the
staged manifest on the laptop and again in the guest (`bundle_check_exit=0`).

QEMU: `q35,accel=kvm`, `-cpu host`, 4 vCPU, 6144 MB,
`-device virtio-gpu-pci`, `-display none`, user-mode NAT with an ssh hostfwd.

## Boot 1 — install

```
PASS: host compatibility
PASS: dependency preflight
PASS: package set validated
check_exit=0

Setting up regolith-session-cosmic (1.2.0-1ubuntu1-3-1regolith-resolute)...
PASS: installed exactly 7 packages
install_exit=0

regolith-session-cosmic   installed 1.2.0-1ubuntu1-3-1regolith-resolute
regolith-session-common   installed 1.2.0-1ubuntu1-2-1regolith-resolute
regolith-inputd           installed 0.4.1-2-1regolith-resolute
regolith-displayd         installed 0.3.4-1-1regolith-resolute
cosmolith                 installed 0.1.0-1-1regolith-resolute
cosmic-settings           installed 1.0.12-1-1regolith-resolute
cosmic-settings-daemon    installed 0.1.0-1-1regolith-resolute
cosmic-session            installed 1.0.0-1-1regolith-resolute
cosmic-comp               installed 0.1-1-1regolith-resolute
dpkg --audit -> audit_exit=0 ; GNOME grep -> gnome_grep_exit=1
```

Installed script is the fixed one:

```
67b7d022986b1e75d5883014bdc58717c7689eba8df3fdce55c53b3196bea22e  /usr/lib/regolith/regolith-session-cosmic-runtime
28:        not-found|"")
```

The failing precondition is still present — this is still a COSMIC-only
install with the legacy units genuinely absent:

```
ls: cannot access '/usr/lib/systemd/user/regolith-gnome.target'
ls: cannot access '/usr/lib/systemd/user/regolith-wayland.target'
ls: cannot access '/usr/lib/systemd/user/regolith-init-powerd.service'
```

and no hand workaround exists:

```
ls: cannot access '/home/rahul/.config/systemd/user/'
ls: cannot access '/etc/systemd/user/regolith-gnome.target'
```

`verify` outside a graphical session: `verify_exit=0`.

## Boots 2, 3, 4 — three independent cold boots of the same overlay

Each is a full power-off and power-on with a separate QEMU process, then a
greetd IPC login. Before every login the checks above re-confirmed that no
user-level mask directory existed.

```
boot 3 boot_id 2f33d24b-d077-456c-8ae4-fe1bd8d7f6fb
boot 4 boot_id 23df9b71-7f6f-43bf-8a4d-f97657d1b3e8
Startup finished in ~0.46s (kernel) + ~2.1s (initrd) + ~3.1s (userspace)
```

(boot 2's `boot_id` was captured on the console but not written to the run log;
its session timestamps, 14:10:23 UTC, are distinct from boot 3's 14:11:18 UTC
and every PID differs. Recorded honestly rather than reconstructed.)

Login, identical on all three:

```
SOCK found
CANCEL_REPLY success
REPLY auth_message secret
REPLY success
SESSION_CMD /usr/bin/regolith-session-cosmic-launch
SESSION_ENV XDG_SESSION_DESKTOP=regolith-cosmic XDG_CURRENT_DESKTOP=Regolith-Wayland XDG_SESSION_TYPE=wayland
START_REPLY success
login_client_exit=0
```

### Session does not abort — boots 2 / 3 / 4

```
boot 2:  2458 /usr/bin/cosmic-session /usr/lib/regolith/regolith-session-cosmic-runtime sway -c /etc/regolith/sway/config
         2460 /bin/bash /usr/lib/regolith/regolith-session-cosmic-runtime ...
         2461 sway -c /etc/regolith/sway/config ; 2504 swaybg ; 2544 swayidle
boot 3:  2378 cosmic-session ; 2380 runtime ; 2381 sway ; 2406 swaybg ; 2475 swayidle
boot 4:  2282 cosmic-session ; 2284 runtime ; 2285 sway ; 2315 swaybg ; 2366 swayidle
```

Journal, whole boot, no restart and no `Stopped target cosmic-session.target`:

```
cosmic-session[2458]: Starting cosmic-session
cosmic-session[2458]: starting process ' COSMIC_SESSION_SOCK=12 /usr/lib/regolith/regolith-session-cosmic-runtime  sway -c /etc/regolith/sway/config'
systemd[2000]: Reached target cosmic-session.target - Cosmic Session Target.
```

This is the direct contrast with the pre-fix run, where the third line was
immediately followed by `Stopped target cosmic-session.target`.

### `regolith-cosmic.target` is-active — boots 2 / 3 / 4

```
active
  regolith-init-cosmic-idle.service loaded active   running
  regolith-init-displayd.service    loaded active   running
  regolith-init-inputd.service      loaded active   running
  regolith-init-kanshi.service      loaded inactive dead
  regolith-cosmic.target            loaded active   active
● regolith-gnome.target             masked inactive dead
```

`regolith-gnome.target` shows `masked` because the fixed runtime masked it
itself, which is what the fix is for. No hand mask was applied at any point in
this run.

### inputd / displayd, and failed units — boots 2 / 3 / 4

```
regolith-init-inputd.service    active
regolith-init-displayd.service  active
systemctl --user --failed  -> 0 loaded units listed.
systemctl --failed         -> 0 loaded units listed.
```

### The abort message is absent — boots 2 / 3 / 4

```
journalctl --user -b | grep -i 'failed to establish mask state'  ->  user_journal_grep_exit=1
journalctl -b        | grep -i 'failed to establish mask state'  ->  system_journal_grep_exit=1
```

### Session identity — boots 2 / 3 / 4

```
XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
WAYLAND_DISPLAY=wayland-1
SWAYSOCK=/run/user/1000/sway-ipc.1000.<pid>.sock
loginctl: Desktop=regolith-cosmic Type=wayland Active=yes State=active
```

### Compositor IPC — boots 2 / 3 / 4

```
swaymsg -t get_version -> "human_readable": "1.11",
                          "loaded_config_file_name": "/etc/regolith/sway/config"
get_version_exit=0
```

### `install-real-system.sh verify` inside the session — boots 2 and 3

```
PASS: desktop entry: /usr/share/wayland-sessions/regolith-cosmic.desktop
PASS: regolith-cosmic.target unit: /usr/lib/systemd/user/regolith-cosmic.target
PASS: regolith-init-inputd.service unit
PASS: regolith-init-displayd.service unit
PASS: regolith-gnome.target absent (GNOME path not installed)
PASS: graphical-session.target active
SKIP: regolith-cosmic.target runtime for desktop unknown
SKIP: regolith-gnome.target runtime for desktop unknown
SKIP: regolith-init-inputd.service runtime for desktop unknown
SKIP: regolith-init-displayd.service runtime for desktop unknown
verify_exit=0
```

Worth flagging: the four `SKIP: ... for desktop unknown` lines are an artifact
of how `verify` was invoked here — `runuser` into the user's bus without
`XDG_CURRENT_DESKTOP` set in that shell, so the script cannot tell which
desktop it is in and skips the per-desktop runtime assertions. `verify` exits
0 but its strongest runtime checks did not actually execute. Not a defect
found today, and not chased; the same assertions were checked directly above
and passed.

### Stability soak, boot 4, +7 minutes

```
up 7 minutes
regolith-cosmic.target        active
regolith-init-inputd.service  active
regolith-init-displayd.service active
systemctl --user --failed  -> 0 loaded units listed.
2282 cosmic-session / 2285 sway / 2315 swaybg / 2366 swayidle
grep 'failed to establish mask state' -> absent, both journals
swaymsg -t get_version -> ipc_exit=0
dpkg --audit -> audit_exit=0
```

### `dpkg --audit`, boots 2 / 3 / 4

```
audit_exit=0
```

## Verdict

The rebuilt `regolith-session-cosmic 1.2.0-1ubuntu1-3-1regolith-resolute`
reaches a live COSMIC session on a fresh COSMIC-only install with **no hand
mask and no other workaround**, on three independent cold boots, and the exact
abort message that killed the pre-fix run is absent from both journals every
time. The defect recorded in the 2026-08-21 blocker note is fixed in a real
package, not only at the shell-function level.

## Criterion 3

**Still `Partial`**, and the reason is now narrow and specific.

The Criterion 3 note kept `Partial` for one stated reason: "the shipped
launcher will not start a COSMIC session on a COSMIC-only install", and three
of its four boots only reached a session through a hand mask. That reason is
gone — this run reached a session three times with nothing applied by hand.

What holds it back from `Met`:

1. The package proven here is built from the fix branch, whose runtime script
   is **not** a superset of the shipped `-2` runtime — it drops the
   `terminate_owned_parent` teardown block and stops shipping
   `regolith-session-gnome-targets`. Until PR #2 is rebased onto the shipped
   lineage and rebuilt, no single package exists that is both fixed and a
   clean successor to the mentor bundle.
2. This run repeated the COSMIC boots only. The discriminating negative
   control — a plain Sway session on the same disk activating none of the
   helpers — is from the earlier run, on a different overlay.
3. QEMU only, headless. No hardware, no enabled output, no pixels. Both
   outputs report `active=False` under `-display none`.
4. Not a stock-Ubuntu clean install: the base image carried the GNOME cascade
   and an older tuple, both purged first.
5. Not an archive install: local debs plus a retained local Resolute pool,
   unsigned, not published.
6. Login was driven over the greetd IPC socket, not through a greeter UI.
7. One user, one seat, one output.

A single re-run of this harness against a rebased build, with the negative
control folded back in, would close 1 and 2 and leave only the standing QEMU
bounds.

## Cleanup

VM powered off cleanly after every boot; no `poweroff` stall this run.
`qemu-img check` on the overlay: `No errors were found on the image.` Overlay,
cloned proof repo, and staging tarball deleted; disposable keypair and
password file shredded and removed, and the guest-side password copy shredded
immediately after each login before any check ran. Neither credential was
printed at any point. Base disk sha256 reconfirmed unchanged after the run.
