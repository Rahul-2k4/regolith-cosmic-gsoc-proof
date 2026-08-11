# Pinned historical `cosmic-session` lifecycle QEMU proof

Date: 2026-08-12
Scope: disposable Ubuntu Resolute QEMU overlay with the historical reduced-
dependency COSMIC session tuple

## Exact package provenance

- Source: [`cosmic-session` `230b601`](https://github.com/Rahul-2k4/cosmic-session/commit/230b601ef189890350eb383ee85fd5343637247b)
- Voulage model: [`5273dd0`](https://github.com/Rahul-2k4/voulage/commit/5273dd0e066c8a38602a1e662ad5b2d5f3462b02)
- Package: `cosmic-session_1.0.0-1-1regolith-resolute_amd64.deb`
- Package SHA-256: `1d9b3479f93d7ab8f51b958b737352763ab3e2f89f1f158367d896bd34221c04`
- Installed `/usr/bin/cosmic-session` SHA-256: `0f4f6b78b2a30e91f43f9c3983eba72d07b36f6dfca6cdadc552c53f3db46b8e`

The exact package was installed into a disposable overlay before reboot. The
canonical QEMU image was not modified.

## Runtime result

- Package installation returned `0`.
- Cold reboot and greetd login returned success.
- `regolith-cosmic.target` was active with inputd/displayd helpers running;
  both reported successful main status and `dpkg --audit` was empty.
- The session exposed `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`.
- Direct `swaymsg exit` returned an IPC error during teardown.
- Sway, the Regolith runtime wrapper, the COSMIC target, and both helpers
  stopped. The exact `cosmic-session` and `dbus-run-session` processes
  remained.
- The journal included `cosmic-comp exited successfully`, but did not include
  the decisive session-loop `EXITING` or `RESTARTING` line.

## Interpretation

This exact historical source/package pair reproduces the parent-session
boundary. The result is therefore not attributable only to the base image.
It still does not prove that the newer metadata-only `a14abe3` package has the
same behavior, so that newer tuple remains separately unverified. The evidence
does not justify adding parent-killing logic to `regolith-session`; the outer
session manager remains the owner of that lifecycle decision.

The supported clean logout proof remains the separate display-manager-owned
`loginctl terminate-session` path. This note does not change the strict status:
**62-68%**, **4 of 12** criteria fully met.
