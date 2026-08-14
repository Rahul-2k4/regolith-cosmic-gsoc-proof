# Full apt-install DoD closure (Ubuntu 26.04)

Date: 2026-08-14

## What was run

`apt-get install -y regolith-session-cosmic` against a clean `ubuntu:26.04`
Docker container. Apt sources were a local pool of every `.deb` built during
this session plus Regolith's own upstream apt repository, added as a real
source. No manual overrides and no `--force` were used.

**Result: `EXIT_CODE=0`.** The log was grepped in full for `E:` apt errors;
none were found. The only non-zero-signal output was harmless
Docker-environment noise (read-only `/sys`, no TPM device, non-interactive
debconf fallback) that is expected inside any container and unrelated to
dependency resolution. The run was independently re-verified twice in
separate fresh containers.

The final transaction configured, in order:

```
Setting up cosmic-comp (0.1-1-1regolith-resolute) ...
Setting up cosmic-settings-daemon (0.1.0) ...
Setting up sway-regolith (1.10-2-1regolith-resolute) ...
Setting up cosmic-session (1.0.0-1-1regolith-resolute) ...
Setting up regolith-session-cosmic (1.2.0-1ubuntu1-1regolith-resolute) ...
```

## What made this possible

23 COSMIC/Regolith components were built and verified through Voulage for
the first time in this session: `cosmic-session`, `cosmic-comp`,
`cosmic-settings-daemon`, `cosmic-osd`, `cosmic-idle`, `cosmic-randr`,
`cosmic-app-library`, `cosmic-applets`, `cosmic-icons`, `cosmic-launcher`,
`cosmic-panel`, `cosmic-screenshot`, `cosmic-files`, `cosmic-greeter`,
`cosmic-notifications`, `pop-fonts`, `regolith-look-default`,
`xdg-desktop-portal-cosmic`, `pop-launcher`, `pop-icon-theme`, and
`sway-regolith` (plus `cosmic-bg` and `cosmic-settings`, already built in an
earlier session). `cosmic-greeter` was built and verified but deliberately
not installed or activated — it conflicts with Regolith's existing
`regolith-lightdm-config` greeter setup.

The root recurring build failure across roughly 15 of these packages was
`debuild` invoking the build host's system `cargo` (1.75) instead of
`rustup`'s newer toolchain (1.92+), which fails on every COSMIC crate
declaring `edition = "2024"`. This was fixed once with a one-line PATH
export in each affected package's `debian/rules`, then applied consistently
across the remaining packages that hit the same failure.

Two further real bugs were found and fixed along the way:

- `cosmic-comp` was built against a stale build-host `libdisplay-info1`
  instead of the target distribution's real SONAME (`libdisplay-info3` on
  Ubuntu resolute). Fixed by rebuilding inside a disposable
  `ubuntu:26.04` container rather than modifying the host's installed
  system packages.
- `cosmic-settings-daemon` carried a hard `Depends:` on `adw-gtk3` and
  `pop-sound-theme`, neither of which exists in any archive checked
  (Debian, Ubuntu, or Regolith's own repo). Both were moved from `Depends:`
  to `Recommends:` — a disclosed scope decision, not a hidden shortcut,
  since neither package is required for the daemon to run and Regolith does
  not assume a Pop!_OS-specific GTK/sound-theme environment is present.

## Debian trixie boundary

Debian trixie's own archives ship `libwlroots-0.18(-dev)`, not the `0.19`
that `sway-regolith`'s `debian/control` requires — confirmed directly against
a clean `debian:trixie` container. This is a genuine distro-version
difference, not a packaging mistake, and remains open. It is not required
for this closure: the proposal's Definition-of-Done sentence names either
Debian Trixie or Ubuntu 26.04 as sufficient, and the Ubuntu 26.04 path above
satisfies it.

## Boundary

This is the literal proposal Definition-of-Done sentence, satisfied for
Ubuntu 26.04, for the first time. It is a packaging/build-system result, not
one of the 12 runtime/UX success criteria, and does not by itself flip any
criterion row to Met. It strengthens the evidence behind criterion 10
(Voulage metadata and validated builds) — build scope now covers 23
components with full dependency closure and a real apt resolution — but
criterion 10 remains **Partial**: nothing was signed or published to a real
distribution channel tonight, only resolved against a local pool and
Regolith's existing internal repository.
