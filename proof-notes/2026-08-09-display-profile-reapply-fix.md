# Display profile reapplication fix - QEMU proof

This note records the single-output persistence fix for the Sway-backed COSMIC
Regolith session. It is QEMU proof, not hardware or native `cosmic-comp` proof.

## Immutable inputs

- `regolith-displayd` source: `817becd9dc7e6a12f13f3f30f663555212ae78fa`
- Voulage model: `c8fba46875d50bf7002e9d90b0ce5a591d9cbc77`
- Voulage exact-SHA checkout fix: `7436101f7ddeddd113f0931ff1ae5b92b53d7bda`
- Package: `regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb`
- SHA-256: `a452caa4e7f1764fe837447ae92a9cfcd666a5ca7aea03c9378edefe0f57e3ba`

Voulage built the package with `BUILD_RC=0`. The package still has the known
debug-symbol and manual-page lintian findings; it is not presented as a
release-signed artifact.

## Change and test

The earlier Kanshi service condition depended on `XDG_CURRENT_DESKTOP` during
unit startup. In practice, the COSMIC target was active before that environment
was available, so Kanshi was skipped. The fix makes the GNOME and COSMIC
systemd targets the ownership gate and removes that environment-timing race.

The test was:

1. Install the rebuilt displayd package in the disposable QEMU guest.
2. Keep a saved Kanshi profile at `1024x768@60.004Hz` while the live output is
   `1280x800@74.994Hz`.
3. End the graphical session and log in again through the COSMIC greeter.
4. Check the new Sway output and the user-unit journal.

Result:

- `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`
- `regolith-cosmic.target` active
- Kanshi started and logged application of the matching profile
- Sway reported `1024x768@60.004Hz`
- inputd and displayd were healthy with zero restarts
- failed user-unit list was empty

The output was restored to the QEMU baseline after the test.

## Boundary

This closes single-output fresh-login persistence on the Sway-backed QEMU path.
Multi-display, hotplug, mixed DPI, COSMIC Settings-panel behavior, native
COSMIC compositor behavior, hardware testing, and release signing remain open.
