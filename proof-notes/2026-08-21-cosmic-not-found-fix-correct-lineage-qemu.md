# regolith-session-cosmic `-4`: correct lineage AND bug-free, two cold boots plus a negative control

Date: 2026-08-21 (IST) / guest boots 2026-08-21 14:33-14:38 UTC
Kind: **QEMU proof.** Nothing here ran on real hardware. The guest ran headless
(`-display none`), so no check below is a claim about pixels.

Third and final rebuild for the `not-found` legacy-target defect. Supersedes
the `-3` packet (`proof-packets/2026-08-21-rebuilt-cosmic-not-found-fix/`),
which proved the behaviour on the wrong lineage.

## 1. Lineage verified BEFORE building (the step missed the first time)

PR #3: https://github.com/Rahul-2k4/regolith-session/pull/3
base `rahul/session-common-version-fix-20260818`, head
`rahul/cosmic-runtime-not-found-legacy-target-rebased-20260821`.

```
HEAD commit  : 697c4bd67b05411b3c61b319b92d0b9fe06b52b1
PARENT commit: b6c447886c65789ec65b21500ba2cca0a46913c5
BASE  commit : b6c447886c65789ec65b21500ba2cca0a46913c5
parent==base : YES
merge-base --is-ancestor BASE HEAD : YES

sha256 usr/lib/regolith/regolith-session-cosmic-runtime
  @ HEAD   46d41aa4aed75d211785be445aafda88276c0c92a32b27cf8e9fe9d3d45956e3
  @ PARENT 8cca2fb4c787d4ffd527a8a8224e25107b4932b3b0444cbd0a1d17346e3db3e5
  @ BASE   8cca2fb4c787d4ffd527a8a8224e25107b4932b3b0444cbd0a1d17346e3db3e5
```

`8cca2fb4...` is the hash of the script inside the **shipped**
`1.2.0-1ubuntu1-2-1regolith-resolute` deb. The commit immediately below the
fix therefore *is* the shipped runtime, byte for byte. This is a genuine
"shipped package plus a `not-found` arm", which the `-3` build was not.

The whole delta from the shipped script is additive:

```
$ git diff PARENT HEAD -- usr/lib/regolith/regolith-session-cosmic-runtime
@@ regolith_legacy_target_is_pre_masked() @@
         enabled|enabled-runtime|linked|linked-runtime|disabled|static|indirect|generated|transient|alias)
             return 1
             ;;
+        not-found|"")
+            # The unit does not exist on this install at all (e.g. a
+            # COSMIC-only install that never pulled in the GNOME-targets
+            # package). That is not masked, so treat it the same as
+            # "disabled": nothing to preserve, safe to mask for COSMIC.
+            return 1
+            ;;
     esac

$ git diff --stat PARENT HEAD
 debian/rules                                       |  1 +
 tests/regolith-cosmic-runtime-not-found-legacy-target.sh | 57 +++++++++++
 usr/lib/regolith/regolith-session-cosmic-runtime   |  7 +++
 3 files changed, 65 insertions(+)
```

Nothing removed. The teardown feature the `-3` lineage dropped is still here,
in the source and in the built deb:

```
138:regolith_cosmic_runtime_terminate_owned_parent() {
169:    regolith_cosmic_runtime_terminate_owned_parent
```

This branch also still builds `regolith-session-gnome-targets`, which the `-3`
branch had stopped doing.

## 2. Package build

Build branch `rahul/cosmic-runtime-not-found-legacy-target-rebased-20260821-build4`,
commit `1628b4f` = PR #3 head `697c4bd` plus one `debian/changelog` entry and
nothing else:

```
$ git diff --stat <PR#3 head> build4
 debian/changelog | 9 +++++++++
 1 file changed, 9 insertions(+)
```

Version `1.2.0-1ubuntu1-4-1regolith-resolute`, prepended above the shipped
`-2-1regolith-resolute` entry (the `-3` build had replaced that entry, because
its lineage never had it).

Built through the normal Voulage local path on the laptop:

```
$ .github/scripts/local-build.sh \
    --extension <voulage>/.github/scripts/ext-debian.sh \
    --git-repo-path <voulage> \
    --package-name regolith-session \
    --package-url <local regolith-session clone> \
    --package-ref rahul/cosmic-runtime-not-found-legacy-target-rebased-20260821-build4 \
    --distro ubuntu --codename resolute --stage unstable
BUILD_RC=0
```

`--package-url` points at the on-disk clone rather than GitHub, so no build
branch was pushed anywhere public. The ref is otherwise identical to PR #3's
head.

`debian/rules` runs the regression test on every build, and it passed inside
`BUILD_RC=0`:

```
bash tests/regolith-cosmic-runtime-teardown.sh
bash tests/regolith-cosmic-runtime-not-found-legacy-target.sh
PASS: COSMIC session proceeds when legacy units are genuinely absent
bash tests/regolith-systemd-targets.sh
systemd target metadata: PASS
```

```
dpkg-deb: building package 'regolith-session-cosmic' in
  '../regolith-session-cosmic_1.2.0-1ubuntu1-4-1regolith-resolute_amd64.deb'.

sha256(regolith-session-cosmic_1.2.0-1ubuntu1-4-1regolith-resolute_amd64.deb)
  = 3e2c58752fd4cd65ca710f8db440434bdc4eed0641c2753f31aa4686e35539a7
```

Lintian produced no new errors relative to previous builds of this source.

## 3. The deb carries the fix byte-for-byte, against PR #3's head

```
$ dpkg-deb -x <deb> /tmp/deb4x
$ git show 697c4bd:usr/lib/regolith/regolith-session-cosmic-runtime > /tmp/src-runtime4
$ cmp /tmp/src-runtime4 /tmp/deb4x/usr/lib/regolith/regolith-session-cosmic-runtime
RUNTIME_BYTE_IDENTICAL_TO_PR3_HEAD=yes
46d41aa4aed75d211785be445aafda88276c0c92a32b27cf8e9fe9d3d45956e3  /tmp/src-runtime4
46d41aa4aed75d211785be445aafda88276c0c92a32b27cf8e9fe9d3d45956e3  /tmp/deb4x/usr/lib/regolith/regolith-session-cosmic-runtime
```

`Depends:` on `regolith-session-common` is unversioned, so pairing the `-4`
cosmic deb with the bundle's `-2` common deb is a legal install.

## 4. Guest setup

Fresh copy-on-write overlay off the unmodified base
`.vm/disk/ubuntu-26.04-resolute-qual.qcow2`, created for this run and not
reused. Base sha256 identical before and after:

```
before  a2c089fd5bf33b310057759abb04eb06f72faa10699f109ff416d2a8a300d226
after   a2c089fd5bf33b310057759abb04eb06f72faa10699f109ff416d2a8a300d226
```

The base carries the GNOME cascade and an older tuple, including
`regolith-session-cosmic 1.2.0-1ubuntu1-1regolith-resolute`. Both were purged
before the bundle install, so this is a genuine new install rather than a
version bump:

```
purge_exit=0 ; autoremove_exit=0 ; tuple_purge_exit=0
regolith-session-cosmic / -common / -gnome-targets / regolith-inputd /
regolith-displayd / cosmolith / cosmic-settings / cosmic-settings-daemon
  -> all ABSENT
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

QEMU: `q35,accel=kvm`, `-cpu host`, 4 vCPU, 6144 MB, `-device virtio-gpu-pci`,
`-display none`, user-mode NAT with an ssh hostfwd.

## 5. Installer and bundle identity

`Rahul-2k4/regolith-cosmic-gsoc-proof` `main`, HEAD `31e23b6`.

```
218b210e5287663b478b755317a45ea33dee3feaea5a5397b55170334868aac0  scripts/install-real-system.sh
```

identical on the laptop and inside the guest.

**Staged bundle deviation, disclosed:** the six other bundle debs are the
unmodified committed artifacts. `regolith-session-cosmic_-2-...deb` was
replaced by the rebuilt `-4` deb, and the corresponding manifest line was
updated. `git diff --stat` on the staged clone shows exactly that and nothing
else. All seven debs verified `OK` against the staged manifest on the laptop
and again in the guest (`bundle_check_exit=0`).

## 6. Boot 1 — install

```
PASS: host compatibility
PASS: dependency preflight
PASS: package set validated
check_exit=0

Setting up regolith-session-cosmic (1.2.0-1ubuntu1-4-1regolith-resolute)...
PASS: installed exactly 7 packages
install_exit=0

regolith-session-cosmic   installed 1.2.0-1ubuntu1-4-1regolith-resolute
regolith-session-common   installed 1.2.0-1ubuntu1-2-1regolith-resolute
regolith-session-gnome-targets  not-installed
regolith-inputd           installed 0.4.1-2-1regolith-resolute
regolith-displayd         installed 0.3.4-1-1regolith-resolute
cosmolith                 installed 0.1.0-1-1regolith-resolute
cosmic-settings           installed 1.0.12-1-1regolith-resolute
cosmic-settings-daemon    installed 0.1.0-1-1regolith-resolute
cosmic-session            installed 1.0.0-1-1regolith-resolute
cosmic-comp               installed 0.1-1-1regolith-resolute
dpkg --audit -> audit_exit=0 ; GNOME grep -> gnome_grep_exit=1
```

Installed script is the fixed one, and still has the teardown block:

```
46d41aa4aed75d211785be445aafda88276c0c92a32b27cf8e9fe9d3d45956e3  /usr/lib/regolith/regolith-session-cosmic-runtime
29:        not-found|"")
138:regolith_cosmic_runtime_terminate_owned_parent() {
169:    regolith_cosmic_runtime_terminate_owned_parent
```

The failing precondition is present — a COSMIC-only install with the legacy
units genuinely absent, and no hand workaround anywhere:

```
ls: cannot access '/usr/lib/systemd/user/regolith-gnome.target'
ls: cannot access '/usr/lib/systemd/user/regolith-wayland.target'
ls: cannot access '/usr/lib/systemd/user/regolith-init-powerd.service'
ls: cannot access '/home/rahul/.config/systemd/user/'
ls: cannot access '/etc/systemd/user/regolith-gnome.target'
```

`verify` outside a graphical session: `verify_exit=0`.

## 7. Boots 2 and 3 — two independent cold boots, COSMIC session

Each is a full power-off and power-on with a separate QEMU process, then a
greetd IPC login. No hand mask at any point.

```
boot 2  boot_id 302c4af8-5695-4cec-a2ac-9f0543369dc4   14:35:20 UTC
boot 3  boot_id 814b185e-008c-4ec3-b010-861a773c252c   14:36:12 UTC
Startup ~0.47s kernel + ~2.1s initrd + ~2.9-3.1s userspace
```

Pre-login on both: no `~/.config/systemd/user/`, no
`/etc/systemd/user/regolith-gnome.target`.

Login, identical on both:

```
SOCK found ; CANCEL_REPLY success ; REPLY auth_message secret ; REPLY success
SESSION_CMD /usr/bin/regolith-session-cosmic-launch
SESSION_ENV XDG_SESSION_DESKTOP=regolith-cosmic XDG_CURRENT_DESKTOP=Regolith-Wayland XDG_SESSION_TYPE=wayland
START_REPLY success ; login_client_exit=0
```

### Session does not abort, compositor stays up

```
boot 2: 2375 cosmic-session ; 2377 runtime ; 2378 sway -c /etc/regolith/sway/config
        2437 swaybg ; 2458 swayidle -w timeout 300 gtklock
boot 3: 2457 cosmic-session ; 2459 runtime ; 2460 sway ; 2489 swaybg ; 2543 swayidle
```

Journal, whole boot, no restart and no `Stopped target cosmic-session.target`:

```
cosmic-session[2375]: Starting cosmic-session
cosmic-session[2375]: starting process ' COSMIC_SESSION_SOCK=12 /usr/lib/regolith/regolith-session-cosmic-runtime  sway -c /etc/regolith/sway/config'
systemd[1984]: Reached target cosmic-session.target - Cosmic Session Target.
```

Direct contrast with the pre-fix run, where the third line was immediately
followed by `Stopped target cosmic-session.target`.

### `regolith-cosmic.target` and helpers — boots 2 and 3

```
active
  regolith-init-cosmic-idle.service loaded active   running
  regolith-init-displayd.service    loaded active   running
  regolith-init-inputd.service      loaded active   running
  regolith-init-kanshi.service      loaded inactive dead
  regolith-cosmic.target            loaded active   active
● regolith-gnome.target             masked inactive dead
```

`regolith-gnome.target` is masked because the fixed runtime masked it itself —
that is what the fix does. No hand mask was applied.

```
regolith-init-inputd.service    active
regolith-init-displayd.service  active
systemctl --user --failed  -> 0 loaded units listed.
systemctl --failed         -> 0 loaded units listed.
```

### The abort message is absent — boots 2 and 3

```
journalctl --user -b | grep -i 'failed to establish mask state'  ->  user_journal_grep_exit=1
journalctl -b        | grep -i 'failed to establish mask state'  ->  system_journal_grep_exit=1
```

### Session identity and compositor IPC — boots 2 and 3

```
XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
WAYLAND_DISPLAY=wayland-1
SWAYSOCK=/run/user/1000/sway-ipc.1000.<pid>.sock
loginctl: Desktop=regolith-cosmic Type=wayland Active=yes State=active

swaymsg -t get_version -> "human_readable": "1.11",
                          "loaded_config_file_name": "/etc/regolith/sway/config"
get_version_exit=0
dpkg --audit -> audit_exit=0
```

### `install-real-system.sh verify` — runtime assertions actually ran this time

The `-3` run invoked `verify` through `runuser` without `XDG_CURRENT_DESKTOP`
in the invoking shell, so the script could not tell which desktop it was in
and skipped its four strongest checks while still exiting 0. Here the value is
read out of the session's own systemd environment and propagated:

```
propagating XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
PASS: desktop entry: /usr/share/wayland-sessions/regolith-cosmic.desktop
PASS: regolith-cosmic.target unit
PASS: regolith-init-inputd.service unit
PASS: regolith-init-displayd.service unit
PASS: regolith-gnome.target absent (GNOME path not installed)
PASS: graphical-session.target active
PASS: regolith-cosmic.target active
SKIP: regolith-gnome.target runtime (unit not installed)
PASS: regolith-init-inputd.service active
PASS: regolith-init-displayd.service active
verify_exit=0
```

Identical on boots 2 and 3. The one remaining `SKIP` is correct: the unit is
genuinely not installed on a COSMIC-only system.

## 8. Boot 4 — negative control, plain non-COSMIC Sway session

Same overlay, same disk, same packages, same compositor binary and the same
`/etc/regolith/sway/config`. The only change is the session greetd was asked
to start.

```
boot_id d1a6f7c5-0080-42f7-a42d-5aa1c4144475
regolith-session-cosmic 1.2.0-1ubuntu1-4-1regolith-resolute
46d41aa4...  /usr/lib/regolith/regolith-session-cosmic-runtime
ls: cannot access '/home/rahul/.config/systemd/user/'

SESSION_CMD /usr/bin/sway -c /etc/regolith/sway/config
SESSION_ENV XDG_SESSION_DESKTOP=sway XDG_CURRENT_DESKTOP=sway XDG_SESSION_TYPE=wayland
START_REPLY success ; login_client_exit=0
```

A compositor really is up, so the control is valid:

```
1972 /usr/bin/sway -c /etc/regolith/sway/config
2082 swaybg
pgrep -a cosmic-session -> cosmic_session_pgrep_rc=1   (no cosmic-session at all)
```

And none of the Regolith machinery activated:

```
systemctl --user is-active regolith-cosmic.target -> inactive (rc=3)
  regolith-init-inputd.service        inactive
  regolith-init-displayd.service      inactive
  regolith-init-kanshi.service        inactive
  regolith-init-cosmic-idle.service   inactive

systemctl --user is-enabled regolith-gnome.target -> not-found (rc=4)
ls /run/user/1000/systemd/user/regolith-gnome.target -> No such file or directory
```

The runtime did not mask anything, because it never ran. Session identity:

```
XDG_CURRENT_DESKTOP=sway
SWAYSOCK=/run/user/1000/sway-ipc.1000.1972.sock
loginctl: Desktop=sway Type=wayland State=active
systemctl --user --failed -> 0 loaded units listed.
journalctl --user -b | grep 'failed to establish mask state' -> exit 1 (absent)
```

This is the discriminating result: a live Wayland session on the same disk
with none of the COSMIC helpers running. The `-4` package is gated by session
identity, not always on.

`verify` on this boot reports `SKIP: runtime checks outside graphical session`
and `verify_exit=0`, because a bare `sway` does not raise
`graphical-session.target` in the user manager the way the Regolith launcher
does. Expected for a non-COSMIC session, and consistent with everything above.

## 9. Verdict

`regolith-session-cosmic 1.2.0-1ubuntu1-4-1regolith-resolute` is the first
package that is **both** a clean additive successor to the shipped
`-2-1regolith-resolute` runtime **and** proven to reach a live COSMIC session
on a fresh COSMIC-only install with no hand mask and no other workaround, on
two independent cold boots, with a negative control on the same disk showing
the helpers stay down under a non-COSMIC session.

## 10. Criterion 3

**`Partial` -> `Met`, within the standing QEMU bounds.**

The two reasons the `-3` packet gave for holding at `Partial` are both closed:

1. Lineage. Closed. The package is built from the shipped runtime plus a
   purely additive `not-found` arm; `terminate_owned_parent` and the
   `regolith-session-gnome-targets` binary are both retained. Measured, not
   assumed.
2. Negative control. Closed. Boot 4 above, on the same overlay as boots 2 and
   3, not a different one.

Also closed, as a side effect: `verify`'s runtime assertions actually
executed rather than silently skipping.

What remains true and is **not** claimed as proven:

- QEMU only, headless. No hardware, no enabled output, no pixels.
- Not a stock-Ubuntu clean install: the base carried the GNOME cascade and an
  older tuple, both purged first.
- Not an archive install: local debs plus a retained local Resolute pool,
  unsigned, not published.
- Login was driven over the greetd IPC socket, not through a greeter UI.
- One user, one seat, one output.
- No long stability soak this run (the `-3` packet has a 7-minute soak, but on
  the wrong lineage).

Anyone reading "Met" should read it as "met under the QEMU bounds listed
above", not as a hardware claim.

## 11. Cleanup

VM powered off cleanly after every boot. `qemu-img check` on the overlay ran
clean. Overlay, cloned proof repo, staging tarball, and build worktree
deleted; the disposable keypair and password file were shredded and removed,
and the guest-side password copy was shredded immediately after each login
before any check ran. Neither credential was printed at any point. Base disk
sha256 reconfirmed unchanged after the run.
