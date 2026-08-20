# Ubuntu 26.04 Resolute: first package closure proof, graphical login still blocked

Date: 2026-08-18 (session continuing into 2026-08-19)

## Scope

First-ever attempt in this project at Ubuntu 26.04 Resolute, rather than
Pop!_OS 24.04. Every prior QEMU proof (including today's mentor
seven-package tuple success) ran on Pop!_OS. This directly targets the
proposal's own Definition-of-Done sentence: `apt install
regolith-session-cosmic` resolving cleanly on Debian Trixie **or Ubuntu
26.04**. That line has been `Partial` since at least the 2026-08-17 audit,
with local pool proofs existing only inside disposable containers — never a
QEMU guest, never graphical.

## What passed

- Downloaded `ubuntu-26.04-live-server-amd64.iso`, verified against Ubuntu's
  published `SHA256SUMS`.
- Fully unattended `autoinstall` (Subiquity NoCloud) install completed after
  one fix: the cloud-init seed had to be attached as a `virtio-blk-pci`
  device, not `media=cdrom` — the installer didn't detect the seed data
  under the CD-ROM attachment on the first attempt.
- Confirmed OS identity directly from the booted guest:
  `PRETTY_NAME="Ubuntu 26.04 LTS"`, `VERSION_CODENAME=resolute`.
- Base Regolith dependencies (`sway`, `greetd`, `gtklock`, `swayidle`, etc.)
  resolved from Ubuntu's own `resolute`/`universe` repositories with no
  extra configuration.
- A local package pool was assembled from previously-built `.deb` artifacts
  scattered across `.worktrees/*/pkgpublish/ubuntu/resolute/` on the remote
  host. The first pool build had a real bug: it picked the highest-sorting
  version across *all* distro targets, so a Trixie-suffixed
  `regolith-session-cosmic` build won the version comparison and pulled an
  unsatisfiable Debian-only dependency (`libdisplay-info2`). Rebuilding the
  pool filtered to Resolute-only filenames fixed it — this is the same
  general failure class as the `regolith-session-common` version bug fixed
  earlier today, worth remembering as a project-wide pattern: **filename
  version suffixes must be checked, not just assumed, whenever a package
  pool spans more than one distro target.**
- **`apt-get install -s -y --no-install-recommends regolith-session-cosmic`
  (dry-run) and the real install: both exit `0`.** `dpkg --audit` clean.
  Full dependency closure resolved: `cosmic-session`, `regolith-displayd`,
  `regolith-inputd`, `sway-regolith`, `trawld`/`trawlcat`/`trawldb`,
  `gtklock`, `xwayland`, and the rest of the chain. **This is the first time
  this exact proposal sentence has been proven true on Ubuntu 26.04
  Resolute.**
- The mentor seven-package bundle (SHA-256 re-verified against
  `SHA256SUMS`) installed on top with `--allow-downgrades`; exit `0`,
  `dpkg --audit` clean. Side effect: pulled in `gdm3`/`gnome-shell` as
  Recommends — worked around by installing `greetd`, disabling `gdm3`, and
  pointing `display-manager.service` at `greetd`. **Rerun with
  `--no-install-recommends` next time to avoid this entirely** — it isn't a
  real dependency, just an unpinned Recommends.
- greetd IPC login via the same client script used in today's Pop!_OS proof
  (`greetd-session-cosmic-client.py`) succeeded twice: `CANCEL_REPLY
  success` → `REPLY auth_message` → `REPLY success` → `START_REPLY success`.

## What's still blocked, and why

The COSMIC session process launches and then crashes immediately (exit 1,
a restart attempt then dies with 137). Direct reproduction on the guest
showed the actual cause:

```
libEGL warning: egl: failed to create dri2 screen
[wlr] [EGL] eglInitialize: EGL_NOT_INITIALIZED — "DRI2: failed to create screen"
KMS: DRM_IOCTL_MODE_CREATE_DUMB failed: Permission denied
[wlr] gbm_bo_create failed: Permission denied
regolith-session: failed to isolate legacy Regolith targets; aborting COSMIC session
```

This QEMU guest's `/dev/dri/` only exposed `card0`, a legacy VGA KMS-only
node with no `renderD*` device. Loading `vgem` creates a render node, but
it's `root:video`-owned without a seat-ACL `uaccess` tag, so even a real
greetd/logind session can't get write access to it for buffer allocation.

**This is a QEMU display-plumbing gap specific to this Resolute guest's
launch config, not a packaging problem.** The Pop!_OS rig's QEMU launch
doesn't hit this because of how its virtual display device is configured.
The fix is either a udev rule adding `uaccess` for the vgem-provided card,
or — more realistically — launching this guest with `-device
virtio-gpu-pci` instead of legacy VGA, matching what a real GPU-backed
guest (or real hardware) would provide.

Evidence: serial console screenshot at point of failure, at
`/Users/rahul/Desktop/Gsoc/.tmp/ubuntu-2604-resolute-proof-20260818/resolute-qual-screen.png`
(and installer transcript in the same directory), showing the exact failure
state (`Regolith is launching COSMIC session with Sway...`, dbus activation
of `org.freedesktop.systemd1` exiting with status `1`) — not a fabricated or
rounded-up success screenshot. These are currently local-only artifacts on
this Mac, not yet copied into any git-tracked proof-notes/artifacts folder.

## Current state

- New disk kept for reuse: `.vm/disk/ubuntu-26.04-resolute-qual.qcow2`
  (6.19GB actual, 24GB virtual) on the remote host, with Ubuntu 26.04
  Resolute, the resolved `regolith-session-cosmic` dependency chain, and the
  mentor bundle already installed. Reusing this avoids repeating the
  ~15-minute unattended install and the pool-build fix on the next attempt.
- QEMU was shut down cleanly (`poweroff`, confirmed via HMP) before ending
  this run. The Pop!_OS rig (`pop-cosmic-qual.qcow2`) was never touched;
  its SHA-256 was reconfirmed unchanged.
- The disposable guest's login password was generated fresh for this run
  and shredded from remote scratch space at the end, per this project's
  credential-handling rule — resuming this disk will need a new credential
  set, same as any other disposable QEMU guest here.
- Remote disk space: 34GB free (after reclaiming ~28GB by removing three
  superseded pre-Pop!_OS disk images earlier in this session — see
  `07_Decisions/` if a decision note is warranted, or treat this note as
  that record).
- A reusable local Resolute package pool now exists at
  `.vm/artifacts/local-resolute-pool-20260818-v2/` (136 packages),
  correctly filtered to Resolute-only filenames.

## What this does and does not change

This proves the proposal's `apt install regolith-session-cosmic` sentence
true on Ubuntu 26.04 Resolute for the first time — stronger evidence than
any prior Resolute proof, all of which were container-only, never a QEMU
guest. It does **not** close Criterion 9: a graphical login on this distro
is still unproven, blocked on a specific, understood, fixable QEMU
configuration issue rather than an open-ended unknown. The strict ledger
stays at **62-68%, 5/12** — this strengthens an already-`Partial` criterion
and identifies exactly what would close its remaining gap; it does not
convert a criterion to `Met`.

## Next step, if pursued

Relaunch the same guest with `-device virtio-gpu-pci` in place of the
legacy VGA device, retry the greetd login, and re-run the runtime
verification (`regolith-cosmic.target` active, `regolith-gnome.target`
inactive, both helper daemons active, `XDG_CURRENT_DESKTOP` contains
COSMIC) the same way as today's Pop!_OS proof. If that closes clean, this
becomes the first Ubuntu 26.04 Resolute graphical COSMIC login in the
project's history, and would be strong evidence toward promoting Criterion
9 from `Partial`.
