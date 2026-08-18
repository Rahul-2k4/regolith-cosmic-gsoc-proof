# Install guide and reviewer verification path

**Honesty up front:** packages produced for this GSoC are **unsigned** and
**not** published to a canonical Regolith archive. Installation is from
locally built (or proof-bundle) artifacts only. Do not treat this guide as a
release install path.

## Contents

- [Mentor real-system test](#mentor-real-system-test)
- [What is proven vs targeted](#what-is-proven-vs-targeted)
- [Prerequisites](#prerequisites)
- [Build from source](#build-from-source-voulage-vendored-offline)
- [Install the tuple](#install-the-tuple-unsigned--local-only)
- [Select the session at the greeter](#select-the-session-at-the-greeter)
- [Roll back to the GNOME session](#roll-back-to-the-gnome-session)
- [Verify a successful install](#verify-a-successful-install-in-session)
- [Cheap reviewer path (no VM)](#cheap-reviewer-path-no-vm)
- [Related documents](#related-documents)

## Mentor real-system test

Supported test hosts: amd64 **Pop!_OS 24.04 with COSMIC** (full graphical
QEMU proof exists for this host) and amd64 **Ubuntu 26.04 Resolute**
(package-install proof only — see the caveat in the status table below). The
system must already have working Regolith and COSMIC package sources for
dependencies. The seven project packages come from an unsigned GitHub
prerelease and are checked against the committed SHA-256 manifest.

Install from the review branch:

```sh
git clone --branch codex/mentor-real-system-installer-20260818 --single-branch https://github.com/Rahul-2k4/regolith-cosmic-gsoc-proof.git && cd regolith-cosmic-gsoc-proof && ./scripts/install-real-system.sh install
```

The script does not reboot, stop the display manager, change the default
session, or store the sudo password. It prints the baseline path before the
APT transaction. After installation, log out, select the Regolith COSMIC
session at the greeter, log in, then run:

```sh
./scripts/install-real-system.sh verify
```

**What this exact seven-package bundle has and has not been tested as.**
Component-level proof (package build, Lintian, individual QEMU install) exists
for all seven packages — see the table below. A **six-explicit-file**
variant of this tuple (the same six COSMIC packages, with
`regolith-session-common` resolved as an apt dependency rather than supplied
directly) has a full QEMU proof: install, cold reboot, greetd login, and a
healthy COSMIC session
(`proof-notes/2026-08-10-inputd-candidate-verifier-qemu-runtime.md`). The
current **seven-explicit-file** manifest — where `regolith-session-common` is
supplied as an explicit input alongside the other six — has not yet been run
through a full install-reboot-login controller as one set; see
`proof-notes/2026-08-18-final-cosmic-tuple-settings-daemon-integration.md`
("no seven-explicit-package runtime claim is made here"). This mentor run is
expected to be the first time the exact seven-file bundle is exercised
end-to-end. Report back if `verify` fails — that is useful signal, not a
surprise finding.

Try these four things, understanding the proof-version caveat above (see
[What is proven vs targeted](#what-is-proven-vs-targeted) for exactly which
package versions each claim was measured on):

1. Confirm Regolith COSMIC logs in, while the GNOME target stays inactive.
2. Change keyboard, mouse, or touchpad settings and confirm Regolith follows them.
3. Change a display setting, log out and back in, and check persistence.
4. Try lock, OSD, launcher/workspace keys, and managed logout.

For a pre-install check without system changes:

```sh
./scripts/install-real-system.sh install --dry-run
```

For rollback, pass the exact baseline path printed by the installer:

```sh
./scripts/install-real-system.sh rollback /var/lib/regolith-cosmic-gsoc/<timestamp>
```

Rollback removes packages introduced by this APT transaction. If a package
was already installed and got upgraded, the script reports its old version
for manual restoration. It does not run `autoremove`.

This installer has contract-test coverage
(`tests/install-real-system-contract.sh`), and each of its seven packages has
independent QEMU/build proof. Real-hardware success, and a controller run of
this precise seven-file bundle, are both still pending this mentor run.

Define once:

```sh
WORKSPACE="${WORKSPACE:-$HOME/regolith-cosmic-workspace}"
```

All paths below use `$WORKSPACE`. Do not hard-code personal home directories.

## What is proven vs targeted

| Surface | Status |
|---|---|
| Pop!_OS 24.04 QEMU cold login + six-explicit-file tuple (`regolith-session-common` as a resolved dependency) | Proven (QEMU) |
| This installer's seven-explicit-file bundle, run end-to-end as one set | **Not yet run** — first real attempt is this mentor test |
| Ubuntu 26.04 Resolute: local package install (`apt`) resolves, `dpkg --audit` clean | Proven (disposable container/QEMU package-install only) |
| Ubuntu 26.04 Resolute: graphical cold login / greetd session | **Not proven** — no Resolute graphical QEMU image exists yet |
| Debian Trixie / Ubuntu 26.04 apt availability of build deps | Queried in Docker; see matrix |
| Debian Trixie graphical session | **Not** proven |
| Physical laptop full boot | **Not** proven — see [`KNOWN_LIMITATIONS.md`](KNOWN_LIMITATIONS.md) |
| Signed / archive-published packages | **Not** done |

The four "try these" behaviors above (login, live settings, display
persistence, lock/OSD/logout) were measured against a **slightly different**
package set than the one this installer ships: `regolith-inputd 0.4.1-1`
(this bundle ships `0.4.1-2`, a same-day fix) plus `regolith-wm-config`
(this bundle does not include a standalone wm-config package; the
functionality is expected to come from `regolith-session-common`). Treat
those four items as **expected behavior backed by component proof**, not as
a rerun of the identical bundle. If any of them behave differently on this
exact tuple, that is a real, useful finding for this mentor test — not
evidence the installer is broken.

One unrelated, pre-existing failed unit
(`app-polkit-mate-authentication-agent-1@autostart.service`) appears in the
underlying QEMU proofs referenced above. It is a leftover GNOME-flashback
polkit agent, unrelated to this project's packages, and does not affect the
`Runtime verification failures: 0` result quoted below.

## Prerequisites

- A Linux amd64 build host with Docker (for Voulage/local package builds) and
  a Rust toolchain able to run `cargo test`.
- For session install: a disposable QEMU guest (or equivalent). Proven
  runtime seat: **Pop!_OS 24.04 with COSMIC** QEMU guest running the Regolith
  COSMIC Sway-backed session. Ubuntu 26.04 Resolute has package-install proof
  only (see table above). Debian Trixie is a **build-dep target** only in
  [`BUILD_DEP_MATRIX.md`](BUILD_DEP_MATRIX.md) — no graphical boot on that
  distro was performed.
- Ability to install local `.deb` files with `dpkg` / `apt` in the guest.
- Greeter access so the COSMIC / Regolith session can be selected visibly.

## Build from source (Voulage, vendored offline)

Preferred package path is Voulage local-build with vendored Rust crates and
`--frozen --offline` style verification where the component supports it.
A longer reproduction runbook lives in the project vault
(`09_Final_Docs/2026-08-08-reproduction-runbook.md`); that runbook is a
build-from-source document, not a release install guide.

Sketch (adjust package name, fork URL, and ref to the branch under review):

```sh
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

# Example shape used on the build host — values must match the proof note
# for the artifact you intend to install.
DEBEMAIL=regolith.linux@gmail.com \
DEBFULLNAME="Regolith Linux" \
  .github/scripts/local-build.sh \
  --extension .github/scripts/ext-debian.sh \
  --git-repo-path /tmp/isolated-package-root \
  --package-name <package> \
  --package-url <personal-fork-url> \
  --package-ref <branch> \
  --distro ubuntu --codename resolute --stage unstable
```

Build one package per isolated build root. Sharing `pkgbuild` directories can
delete another package's Rust target during cleanup.

After build, record SHA-256 of every `.deb` before copying into a guest.
Proof-bundle hashes for committed artifacts are listed under
`artifacts/README.md` in this repository.

## Install the tuple (unsigned / local-only)

1. Copy the hash-verified `.deb` files into the guest.
2. Install the staged tuple with `apt-get install ./file.deb ...` so declared
   runtime dependencies are resolved by the guest package manager. The final
   runbook uses this path for the seven project packages.
3. Use `dpkg --audit` after installation. Do not silently substitute a
   different Regolith build or use a mismatched package hash.
4. Reboot or restart the display manager so the greeter reloads session
   desktop files.

## Select the session at the greeter

At the COSMIC / display-manager greeter, select the Regolith COSMIC
(Sway-backed) session entry, then log in. Visible greeter selection is part
of the accepted QEMU proofs; do not claim success from an SSH-only
environment variable export.

## Roll back to the GNOME session

1. Log out to the greeter (prefer display-manager logout /
   `loginctl terminate-session` over raw `swaymsg exit` — see limitations).
2. Select the GNOME / Regolith-GNOME session entry.
3. If packages must be removed, use `dpkg -r` / `apt remove` on the local
   COSMIC tuple packages, then restore any saved baseline `.deb` set from
   your proof packet. Keep a pre-install package list / checksums before
   experimenting.

Direct `swaymsg exit` is **not** a clean parent teardown: it can leave
`cosmic-session` / `dbus-run-session` alive.

## Verify a successful install (in-session)

Do not invent fresh QEMU output here. The following values were recorded by
the inputd candidate verifier on 2026-08-10 (six-explicit-file tuple; see the
proof-version caveat above) and are quoted from
[`proof-notes/2026-08-10-inputd-candidate-verifier-qemu-runtime.md`](../proof-notes/2026-08-10-inputd-candidate-verifier-qemu-runtime.md)
and its artifact files under
`artifacts/inputd-candidate-verifier-qemu-20260810/`.

Quoted environment / target evidence from that proof:

```text
XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
regolith-cosmic.target=active
regolith-gnome.target=inactive
```

From the same note's result summary:

- no `gnome-session-bin` process;
- `regolith-init-inputd.service` and `regolith-init-displayd.service` both
  `ActiveState=active`, `Result=success`, `NRestarts=0`;
- one unrelated pre-existing failed unit,
  `app-polkit-mate-authentication-agent-1@autostart.service` (GNOME-flashback
  polkit agent leftover, not part of this project);
- verifier: `Runtime verification failures: 0`.

Artifact files that hold those strings:

- `artifacts/inputd-candidate-verifier-qemu-20260810/04-sway-environment.txt`
- `artifacts/inputd-candidate-verifier-qemu-20260810/04-regolith-inputd-environment.txt`
- `artifacts/inputd-candidate-verifier-qemu-20260810/05-regolith-cosmic.target.txt`
- `artifacts/inputd-candidate-verifier-qemu-20260810/05-regolith-gnome.target.txt`
- `artifacts/inputd-candidate-verifier-qemu-20260810/06-regolith-init-inputd.service.txt`
- `artifacts/inputd-candidate-verifier-qemu-20260810/06-regolith-init-displayd.service.txt`
- `artifacts/inputd-candidate-verifier-qemu-20260810/07-user-failed-units.txt`
- `artifacts/inputd-candidate-verifier-qemu-20260810/11-result.txt`

A reviewer reproducing on a live guest should expect the same shape of
checks (desktop token, no `gnome-session-bin`, cosmic target active, gnome
target inactive, helpers active). Exact PIDs will differ per boot.

## Cheap reviewer path (no VM)

A reviewer who will not build a guest can still verify source tests. The
commands below were run on the build host on 2026-08-10 against the HEADs
shown. Outputs are real; do not treat them as QEMU runtime proof.

### `regolith-inputd`

- Branch: `rahul/inputd-touchpad-lintian-reconciled-20260811`
- Commit: `e641b434c76c70e9a21e492adea577607e096d03`

```sh
cd "$WORKSPACE/regolith-inputd"
git checkout e641b434c76c70e9a21e492adea577607e096d03
cargo test --no-default-features --features cosmic
# observed: test result: ok. 46 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.01s
cargo test --all-features
# observed: test result: ok. 49 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.01s
cargo test
# observed: test result: ok. 22 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

All three feature configurations must pass (GNOME coexistence commitment).

### `regolith-displayd`

- Branch: `worker/displayd-frozen-gap-20260810`
- Commit: `817becd9dc7e6a12f13f3f30f663555212ae78fa`

```sh
cd "$WORKSPACE/regolith-displayd"
git checkout 817becd9dc7e6a12f13f3f30f663555212ae78fa
cargo test
# observed lib tests:  test result: ok. 48 passed; 0 failed; ... finished in 1.12s
# observed next crate: test result: ok. 25 passed; 0 failed; ... finished in 0.01s
```

### `cosmolith`

- Branch: `fix/startup-xkb-events-atomic`
- Commit: `f7543ebe99399a7b61955ad822577923582ce1bf`

```sh
cd "$WORKSPACE/cosmolith"
git checkout f7543ebe99399a7b61955ad822577923582ce1bf
cargo test
# observed: test result: ok. 2 passed; 0 failed; ... (repeated for a second
# test target also reporting 2 passed; 0 failed)
```

### `regolith-session` (shell regression suite)

- Branch: `rahul/flashback-gnome-target-20260811`
- Commit: `b12b837dba44e6f0c7b8eede428eee09cb4d0c31`

```sh
cd "$WORKSPACE/regolith-session"
git checkout b12b837dba44e6f0c7b8eede428eee09cb4d0c31
pass=0
for t in tests/*.sh; do bash "$t" && pass=$((pass+1)); done
echo "SUMMARY pass=$pass"
# observed: eight scripts, all exit 0
#   regolith-cosmic-autostart.sh
#   regolith-cosmic-idle-fallback.sh
#   regolith-cosmic-launch.sh
#   regolith-cosmic-powerd-runtime.sh
#   regolith-cosmic-runtime-environment.sh
#   regolith-cosmic-runtime-teardown.sh
#   regolith-cosmic-status-bar.sh
#   regolith-systemd-targets.sh
# SUMMARY pass=8 fail=0
```

Notable PASS lines seen during the run:

```text
COSMIC idle fallback: PASS
COSMIC powerd ownership: PASS
COSMIC runtime environment lifecycle: PASS
systemd target metadata: PASS
```

## Related documents

- [`KNOWN_LIMITATIONS.md`](KNOWN_LIMITATIONS.md) — hardware / upstream /
  protocol / lifecycle / distribution / scope boundaries
- [`BUILD_DEP_MATRIX.md`](BUILD_DEP_MATRIX.md) — cosmic-epoch Build-Depends
  and Trixie / 26.04 apt candidates
- [`../WORK_PRODUCT.md`](../WORK_PRODUCT.md) — claim table and proof links
