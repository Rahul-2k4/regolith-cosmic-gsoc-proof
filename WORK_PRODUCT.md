# Build a COSMIC-based Wayland Session for Regolith

This is the stable reviewer-facing work-product page for the Regolith COSMIC
proof bundle. It records only evidence in this repository and the latest
sanitized wrapper proof.

## Proposal success criteria: 4 of 12 fully met

| # | Criterion | Status | Scope |
|---|---|---|---|
| 1 | Fresh login into COSMIC-backed session | Met | QEMU |
| 2 | `gnome-session-bin` absent, `cosmic-session` PID, correct desktop token | Met | QEMU |
| 3 | Multi-display hotplug / mixed DPI / persistence on hardware | Not met | hardware unavailable |
| 4 | Keyboard layout + variant via cosmic-settings reflected in Sway | Not met as written | Settings panel crashes; propagation proven via config mutation |
| 5 | Shipped lock/unlock validated end-to-end on Sway | Met | QEMU |
| 6 | OSDs render correctly | Partial | volume OSD only; media keys uninjectable in QEMU |
| 7 | Settings persist across reboot | Partial | single-output display profile only |
| 8 | Retained surface (workspaces, i3status-rs, ilia) works | Partial | ilia not observable headless |
| 9 | Package audit: GNOME session/bootstrap removed, survivors justified | Partial | runtime absence proven; transitive audit open |
| 10 | Voulage metadata + validated builds, publication coordinated | Partial | builds proven; unsigned, unpublished |
| 11 | Vendored tarballs for all Rust-heavy components, offline verified | Met | 35+ packages, `--frozen --offline` |
| 12 | Keyboard-first workflow preserved via Sway `bindsym` | Unproven | config presence only, no interactive verification |

The public branch includes the reviewed
[inputd candidate QEMU verifier](scripts/verify-inputd-candidate-qemu-runtime.sh),
introduced in `cedcd52` and hardened in `f8a84a0`. It checks an already-installed session without
installing packages, restarting services, or changing persistent
configuration. It requires the expected package version and binary SHA-256,
checks COSMIC/GNOME target boundaries, helper dependency membership, zero
restarts, and allowlisted process-environment values. With `INPUTD_HELPER`,
live input settings are temporarily changed and restored; that mode is not
purely read-only.

## Source of truth

The public source of truth is the `main` branch of this repository. Per-claim
commit references appear inline in the code inventory below.

This page is a proof bundle, not an upstream merge. No upstream PR or `main`
merge is claimed, and no hardware result is claimed.

**Acceptance-boundary note:** the submitted PDF used “legacy helper units
inactive” as its success wording. Mentor feedback later approved separate
GNOME/COSMIC systemd targets, with the COSMIC target owning the compatible
inputd and displayd helpers. The current proof therefore expects those helpers
to be active under `regolith-cosmic.target`, with successful results, zero
restarts, and no GNOME session bootstrap. This is the current implementation
boundary; it is not a claim that the original PDF wording was tested unchanged.

**Voulage provenance correction:** corrected model commit
[`f38278934be32e9d051390b19cc416c3f320e7e5`](https://github.com/Rahul-2k4/voulage/commit/f38278934be32e9d051390b19cc416c3f320e7e5) restores session source `3523047b`,
was rebuilt into the exact unsigned session package, installed in QEMU, and
exercised through the real greeter. See the [corrected-model proof](proof-notes/2026-08-10-corrected-voulage-model-real-greeter.md).

The separate Voulage branch
[`codex/voulage-cosmic-pin-regression-20260810`](https://github.com/Rahul-2k4/voulage/commit/abbf6562dd670637d9c7fa70284befc5dba01fd6)
adds a regression test for the exact immutable source pins of the frozen
session, inputd, and displayd package model. The test passes; this is model
integrity evidence, not a new package build or release claim.

## Proven areas

- **Final-tuple wrapper closure (QEMU):** two sequential cold boots of the
  installed final package tuple returned to the Sway-backed Regolith Wayland
  COSMIC session. The target/helper health checks passed on both logins.
  [Sequential cold-login proof](proof-notes/2026-08-09-final-tuple-sequential-cold-login-proof.md)
- **Corrected Voulage model runtime (QEMU):** the exact package built from model
  `f38278934be32e9d051390b19cc416c3f320e7e5` and session source `3523047b`
  launched through the real QEMU greeter. The package version, target-owned
  helper health, `dpkg --audit`, and rollback checksum are recorded in the
  [corrected-model proof](proof-notes/2026-08-10-corrected-voulage-model-real-greeter.md).
- **Target ownership (QEMU):** the COSMIC target owned healthy `regolith-inputd`
  and `regolith-displayd` helpers, while the GNOME target remained separate and
  inactive for that COSMIC login.
  [Current tuple acceptance](proof-notes/2026-08-09-current-tuple-acceptance.md)
- **Input keyboard path:** keyboard layout, variant, and repeat propagation
  into Sway, plus focused COSMIC layout/variant event tests.
  [COSMIC keyboard event tests](proof-notes/2026-08-09-cosmolith-input-tests.md)
- **Current-hash inputd runtime (QEMU):** source `e32d049`, package
  `0.4.1-1-1regolith-resolute`, and a QEMU COSMIC cold login with the active
  inputd service and COSMIC backend environment. One keyboard/input-source
  transition was observed and then restored.
  [Current-hash inputd QEMU proof](proof-notes/2026-08-09-current-hash-inputd-qemu-proof.md)
- **Inputd touchpad mapping coverage:** the frozen source already passes 43
  COSMIC-feature tests and 20 GNOME-feature tests, including deterministic
  touchpad command mappings and partial configurations. This is unit coverage;
  physical-device and live reverse-sync behavior remain open.
  [Touchpad coverage audit](proof-notes/2026-08-10-inputd-touchpad-coverage-audit.md)
- **Inputd robustness and packaging candidate:** source `cd1c2cd` guards empty
  Sway keyboard-layout metadata and passes 46 all-feature tests. Packaging
  commit `b380c9a` adds `regolith-inputd(8)` and DWARF data. Voulage model
  commit `4dc7de8` builds an unsigned Ubuntu Resolute amd64 package with
  SHA-256 `759f87dc908182359a17d3930bf67b0f4c3a188fe02e75bdc71f7bd9238ff193`.
  Direct Debian Lintian is clean; Voulage retains one same-day changelog-date
  warning. The candidate remains separate from the frozen installed tuple.
  The separate candidate verifier proof below covers target-owned service
  health after an isolated QEMU install. It does not turn this source/test
  note into runtime proof for `cd1c2cd`, and the candidate is still separate
  from the frozen `e32d049` source tuple pending mentor/release direction.
  [Empty-layout guard proof](proof-notes/2026-08-10-inputd-empty-layout-guard.md)
- **Candidate verifier runtime (QEMU):** the hardened verifier passed in
  qualification QEMU after a visible greeter login with the exact candidate
  package version and installed-binary hash. It proved COSMIC target selection,
  GNOME target exclusion, helper health, zero restarts, target dependency
  membership, and allowlisted process environment values. The guest proof
  intentionally excludes unrelated failed units and does not claim hardware or
  native compositor coverage.
  [Verifier QEMU proof](proof-notes/2026-08-10-inputd-candidate-verifier-qemu-runtime.md)
- **Inputd package artifact:** the exact unsigned package and its metadata are
  recorded in the [Voulage package proof](proof-notes/2026-08-10-inputd-voulage-package-proof.md).
- **Cosmolith source closure:** the personal fork now has structured watcher
  errors and deterministic COSMIC session detection. A clean local `cargo test`
  run passed with 14 tests and no failures. This is a source-level result on
  the build machine, not a hardware session result.
  [Cosmolith source closure](proof-notes/2026-08-09-cosmolith-source-closure.md)
- **Single-output persistence (QEMU):** fresh-login display profile
  reapplication passed on the Sway-backed QEMU path.
  [Display profile reapplication proof](proof-notes/2026-08-09-display-profile-reapply-fix.md)
- **Wayland display observer:** the frozen displayd source
  `rahul/displayd-kanshi-target-safe-20260809` at `817becd9` already contains
  and wires the `zwlr_output_manager_v1` observer for COSMIC, while retaining
  Sway IPC for compatibility and fallback. Single-output fresh-login
  persistence is proven (QEMU) in the frozen Sway-backed wrapper. The older
  `e8cc8e07` package note remains useful as direct observer evidence, but no
  repin is needed. The frozen source audit passes 73 locked tests and found no
  safe patch to transplant from the newer candidate. Native `cosmic-comp`,
  hotplug, mixed-DPI, and Settings-panel proof are still open.
  [Wayland observer proof](proof-notes/2026-08-04-cosmic-wayland-observer-qemu-proof.md)
  [Frozen source audit](proof-notes/2026-08-10-displayd-frozen-source-audit.md)
- **Displayd clean build:** Voulage clean-clone build `9c88f6fe` produced 12
  passing tests with 142 vendored crates. Lintian: non-clean, warnings remain.
  This artifact was **not** installed for the runtime checks below.
- **Displayd runtime (QEMU):** runtime claims are tied to the installed artifact
  `766a2a19`. A live `1024x768` recording restored to `1280x800` after one cold
  reboot in the QEMU guest.
  [Displayd runtime artifact proof](proof-notes/2026-08-09-displayd-runtime-artifact-proof.md)
- **Displayd packaging cleanup:** personal-fork source commit `39c3746c`
  adds the two manual pages, corrects Debian metadata, and adds a packaging
  regression test. Follow-up branch `c99495e` fixes the historical changelog
  entry and automatic dbgsym generation. Its isolated Voulage artifact has
  clean binary and `.changes` Lintian results, package SHA-256
  `f733551be828ea4ff73043f71ebbd4a955b3d6a06ae3071190e761623a6df512`, and
  the earlier package had a matching disposable-QEMU install with empty
  `dpkg --audit`.
  [Displayd packaging proof](proof-notes/2026-08-09-displayd-packaging-proof.md)
- **Voulage changelog identity (QEMU):** isolated commit `db0ff7b` adds a tested
  maintainer-identity fallback so local Voulage builds do not inherit the
  builder hostname. The corrected branch rebuilt the Resolute COSMIC session
  package and the exact unsigned artifact passed an isolated QEMU install,
  visible login, target/helper checks, and rollback. A follow-up source
  candidate `bdb2b00` adds the COSMIC launcher manpage; its exact Voulage-built
  `regolith-session-cosmic` binary has the manpage payload and standalone
  Lintian-clean output. Sibling session packages still have unrelated legacy
  findings; signing and canonical publication are open.
  [Changelog identity proof](proof-notes/2026-08-10-voulage-changelog-identity-proof.md)
  [Rebuild and QEMU proof](proof-notes/2026-08-10-corrected-voulage-session-rebuild-qemu-proof.md)
  [COSMIC manpage proof](proof-notes/2026-08-10-session-manpage-voulage-proof.md)
- **Voulage builder parser (QEMU):** isolated commit `a8b0e0d` makes the
  documented `--arch` option work and produced the canonical Resolute amd64
  COSMIC session artifact. The exact package hash and Lintian scope are
  recorded in the
  [parser and build proof](proof-notes/2026-08-10-voulage-arch-parser-session-build.md).
  It also passed a QEMU cold-login and matched-baseline rollback check. Native
  display, hardware, signing, and publication remain outside this proof.
- **Idle ownership (QEMU):** the canonical WM-config ownership test passed, and
  the QEMU session confirmed the supported `swayidle` fallback, inactive
  `cosmic-idle`/GNOME target, and empty failed-unit list.
  [Idle ownership proof](proof-notes/2026-08-10-idle-ownership-cold-login.md)
- **Fallback lock (QEMU):** two real five-minute `swayidle -w timeout 300 gtklock`
  timeout-lock/unlock cycles passed on the Sway-backed QEMU path. The
  graphical session returned after each unlock; it reported `Type=wayland`,
  `Desktop=Regolith-Wayland`, `IdleHint=no`, and `LockedHint=no`. After each
  unlock, only `swayidle` remained and the failed user-unit audit was empty.
  Native cosmic-idle/logind semantics, logout/shutdown, hardware, and
  signing/publication remain open.
  [Current tuple fallback lock/unlock proof](proof-notes/2026-08-09-fallback-lock-unlock-current-tuple-qemu-proof.md)
- **OSD (QEMU):** a visible COSMIC volume overlay was produced in the
  Sway-backed COSMIC QEMU session.
  [COSMIC volume OSD proof](proof-notes/2026-08-09-cosmic-osd-volume.md)
- **Vendored/package installation:** clean Voulage builds with vendored
  dependencies and real disposable Trixie installation of the exact package
  tuple are recorded.
  [Clean Voulage rebuild](proof-notes/2026-08-09-clean-voulage-rebuild.md) ·
  [Real disposable Trixie install](proof-notes/2026-08-09-real-trixie-container-install.md)
- **Cosmolith package boundary (QEMU):** the exact `cosmolith` source was built
  through vendoring, offline compilation, Debian source-package generation, and
  binary package creation. The resulting `.deb` was installed in QEMU with
  matching SHA-256 values and an empty `dpkg --audit`. A fresh graphical QEMU
  login then observed the installed `/usr/bin/cosmolith` process with the
  expected COSMIC desktop selector and Wayland/Sway sockets; the target and
  helper health checks were clean.
  [Cosmolith fresh-session QEMU proof](proof-notes/2026-08-09-cosmolith-fresh-session-qemu-proof.md)
- **Runtime-owned helper teardown (QEMU):** the reviewed Sway-backed wrapper
  cleans the Regolith-owned compositor, `cosmolith`, helper process groups, and
  COSMIC targets. A bounded QEMU test confirms that direct `swaymsg exit` leaves
  the parent `cosmic-session`/`dbus-run-session` alive; the display-manager-owned
  logout path remains the clean logout result.
  [Teardown boundary](proof-notes/2026-08-09-runtime-teardown-boundary.md)
  [Sway-exit boundary](proof-notes/2026-08-10-sway-exit-parent-lifecycle-boundary.md)
- **Physical hardware boundary:** a read-only host audit found a physical
  touchpad but no active Regolith/COSMIC session and only the internal display
  connected. No host state was changed; physical touchpad, hotplug, and
  multi-display behavior remain unverified.
  [Hardware capability boundary](proof-notes/2026-08-10-physical-hardware-capability-boundary.md)

## Open boundaries

- Signing, canonical publication, and final release disposition remain open.

- Settings panel display interaction, including its reproducible renderer
  crash.
- Physical or equivalent display matrix: multi-display, hotplug, and mixed
  DPI behavior remain unverified.
- **Inputd touchpad reverse-sync (open):** implemented and unit-tested
  (`46` COSMIC-feature / `49` all-feature tests), packaged, and install-verified
  in a QEMU guest. The code path has never executed: the guest exposes no
  `type:touchpad` device. Physical reverse-sync remains unproven.
  [Touchpad reverse-sync note](proof-notes/2026-08-10-inputd-touchpad-reverse-sync.md)
- Touchpad coverage, input reverse-sync runtime behavior, and a fresh visible
  GNOME desktop selection remain open.
- The inputd candidate runtime note is QEMU-only; it does not claim hardware,
  signing/release, or an upstream merge.
- Full logout and shutdown lifecycle coverage remains open. Reboot ordering and
  two fallback idle timeout-lock/unlock cycles are proven in QEMU; native
  cosmic-idle/logind semantics and hardware remain open. Direct Sway exit
  leaves the parent `cosmic-session`/`dbus-run-session` alive.
- **Managed logout:** `loginctl terminate-session` returned the guest to the
  COSMIC greeter and stopped the COSMIC target plus Regolith helpers. The
  separate `swaymsg exit` parent-process boundary is documented as a QEMU
  boundary rather than a clean parent teardown.
- Signing, release readiness/publication, and final mentor review remain open.
- Signing, the full display matrix, native Settings validation, and hardware
  validation remain open for the newer displayd artifact.

[GNOME coexistence boundary](proof-notes/2026-08-09-gnome-regression-boundary.md) ·
[Inputd reverse-sync tests](proof-notes/2026-08-09-inputd-reverse-sync-tests.md) ·
[Live QEMU runtime boundary](proof-notes/2026-08-09-live-qemu-runtime-recheck.md) ·
[Lintian release audit](proof-notes/2026-08-09-lintian-release-audit.md) ·
[Sequential cold-login proof](proof-notes/2026-08-09-final-tuple-sequential-cold-login-proof.md) ·
[Fallback lock/unlock proof](proof-notes/2026-08-09-fallback-lock-unlock-current-tuple-qemu-proof.md) ·
[Displayd runtime artifact proof](proof-notes/2026-08-09-displayd-runtime-artifact-proof.md)

## Upstream contribution status

| PR / Issue | Repo | State |
|---|---|---|
| PR #15 — bootstrap startup xkb events | `sandptel/cosmolith` | **Merged and approved** 2026-04-21 (`7d47b8b6`) |
| PR #13 — earlier over-scoped version | `sandptel/cosmolith` | Closed, superseded by #15 |
| Issue #1 — session detection | `sandptel/cosmolith` | Open upstream; source complete on fork branch, no PR opened |
| Issue #2 — structured error enum | `sandptel/cosmolith` | Open upstream; source complete on fork branch, no PR opened |

No PR has been opened against `regolith-linux/*`. All session, inputd, displayd,
and Voulage work is on personal fork branches, per 2026-06-19 mentor direction to
hold upstream PRs from proof branches until review shape is agreed. That direction
is the open question in the final mentor message.

## Code inventory

One canonical personal-fork head per component. Every commit link was checked
HTTP 200 on 2026-08-10. Heads prefer the Track C reconciled tips where they
supersede earlier frozen tuple pins.

| Repo | Branch | Commit | What it does | Tests | Upstream status |
|---|---|---|---|---|---|
| `regolith-inputd` | `rahul/inputd-touchpad-lintian-reconciled-20260811` | [`e641b434`](https://github.com/Rahul-2k4/regolith-inputd/commit/e641b434c76c70e9a21e492adea577607e096d03) | COSMIC input backend plus lintian-clean packaging; reconciles touchpad reverse-sync with the packaging pin | cosmic 46 / all-features 49 / gnome-default 22, all 0 failed | Fork only; no `regolith-linux` PR |
| `regolith-session` | `rahul/flashback-gnome-target-20260811` | [`b12b837d`](https://github.com/Rahul-2k4/regolith-session/commit/b12b837dba44e6f0c7b8eede428eee09cb4d0c31) | Moves `regolith-gnome.target` and `gnome-session.target.d` into `regolith-session-common` so flashback and sway co-install without dpkg path collision | 8 shell regression scripts PASS, including systemd target single-owner invariant | Fork only; no `regolith-linux` PR |
| `regolith-displayd` | `rahul/displayd-kanshi-target-safe-20260809` | [`817becd9`](https://github.com/Rahul-2k4/regolith-displayd/commit/817becd9dc7e6a12f13f3f30f663555212ae78fa) | Frozen displayd: Kanshi target-owned startup, Wayland output observer, single-output persistence path | `cargo test --locked`: 73 passed (lib 48 + next 25) | Fork only; tip equals `worker/displayd-frozen-gap-20260810` |
| `cosmolith` | `rahul/cosmolith-rustfmt-20260810` | [`f7543ebe`](https://github.com/Rahul-2k4/cosmolith/commit/f7543ebe99399a7b61955ad822577923582ce1bf) | Startup XKB event watcher plus rustfmt gate on watcher shortcuts | `cargo fmt --check` clean; `cargo test` 2 passed per test target | Fork tip; PR #15 already merged upstream (`7d47b8b6`); issues #1/#2 source-complete, no PR opened. Same SHA as checked-out `fix/startup-xkb-events-atomic` |
| `voulage` | `main` | [`1bbaa39b`](https://github.com/Rahul-2k4/voulage/commit/1bbaa39b0a9a0ef5604a3e72c20ee87afafe42cc) | Personal-fork mainline carries COSMIC package-model entries and the reconciled inputd pin | Model pin regression and related shell checks PASS on proof branches | Fork `main` only (recorded AGENTS.md deviation: land model on personal fork main for reviewer visibility; not upstream `regolith-linux/voulage`) |
| `regolith-wm-config` | `rahul/cosmic-kanshi-owner-wm-config-resource-fallbacks-20260808` | [`10225c05`](https://github.com/Rahul-2k4/regolith-wm-config/commit/10225c056ee3ae15ab5745aba5a86ba611801ed5) | COSMIC kanshi ownership plus safe Sway resource fallbacks for idle/display helpers | Canonical idle-ownership source test PASS; QEMU cold-login ownership proven separately | Fork only; checked-out published tip on personal remote |

## Claim boundary

The wrapper and target-ownership result is QEMU proof. Native `cosmic-comp`
runtime has a separate QEMU proof, but it is not Regolith-wrapper validation:
[native compositor proof](proof-notes/2026-08-09-native-cosmic-comp-qemu-proof.md).
No hardware claim is included here. Upstream status is limited to the table
above; no `regolith-linux/*` PR or Regolith `main` merge is claimed.
