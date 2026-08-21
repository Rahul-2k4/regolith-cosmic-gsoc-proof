# displayd: a real display config was applied and persisted — with a real ceiling and a real bug found

Date: 2026-08-21
QEMU proof only. Nothing ran on hardware.

## The methodology fix that made this possible

Every display-related QEMU proof today used `-device virtio-gpu-pci
-display none`. Under that combination the guest's virtio-gpu connector has
no sink, so no output can ever report `active=true` — every prior "no pixels
were rendered" disclosure this session was correct, but the deeper cause
(the connector had nothing to attach to at all, not a genuine COSMIC/Sway
limitation) hadn't been isolated until this run.

Two backends were tried:

- `WLR_BACKENDS=headless` — produces a real `active=true` output, but
  wlroots headless outputs advertise **zero modes**. `swaymsg output ...
  mode ...` returns `success: true` and changes nothing, the same false
  positive the virtio path gave. displayd correctly refuses to apply an
  advertised-unavailable mode — this is a genuine headless-backend ceiling,
  not a displayd bug. One useful result: `swaymsg create_output` immediately
  made `GetCurrentState` report two monitors — displayd's hotplug detection
  works at the protocol level.
- `-device virtio-vga -vnc 127.0.0.1:31` — gives `Virtual-1` a real sink:
  `active=true`, 26 real advertised modes (640x480 to 5120x2160), each with
  supported scales. This is what actually worked.

**This should be the standard recipe for any future display-config QEMU
proof in this project.** `-display none` alone silently caps what can be
claimed; `-vnc` costs nothing and removes the cap.

## What was proven

Four `ApplyMonitorsConfig` D-Bus calls against the live compositor:

1. `verify` (1920x1080@60Hz) → `()`, Sway state unchanged — correct, this
   method doesn't mutate.
2. `apply-temporary` (1920x1080@60Hz) → `()`, Sway actually changed from the
   session's default 1280x800 to 1920x1080. **Real mode change, applied and
   observed.**
3. `apply-persistent` (3840x2160@60Hz, scale 2.0) → `()`, Sway reflects
   `mode=3840x2160 scale=2.0`.
4. `apply-persistent` (1920x1080@60Hz, scale 1.25) → `()`, Sway reflects
   `mode=1920x1080 scale=1.25 rect=1536x864`.
5. Wrong-serial control → `InvalidArgs: Wrong serial`, as expected.

## Persistence — real, with a negative control

Cold reboot (fresh QEMU process, new boot_id), fresh greetd login, identical
launch args: Sway reports `active=true scale=1.25 rect=1536x864
mode=1920x1080` — the state from apply #4, not the session default. The
first login on this same VM/args had given 1280x800 @ scale 1.0, so this is
not a coincidental default. **Repeated on a second independent cold
reboot**, same result both times.

Mechanism: displayd writes a kanshi profile on `apply-persistent` and
`regolith-displayd-init` replays it at session start. Kanshi itself is not
running — displayd applies the profile directly, consistent with the
COSMIC path being designed to bypass kanshi.

No panics or restarts from `regolith-displayd` across either boot (two
unrelated, pre-existing `xdg-desktop-portal-cosmic` panics excluded).

## Real bug found, disclosed, not fixed this session

Requested `1920x1080@60Hz`. displayd applied and persisted
`1920x1080@50Hz` — `60Hz` was present in the advertised mode list and
marked `is-current: false`, so it wasn't unavailable, it was just not
selected. Mode matching appears to key on resolution only, silently
accepting the wrong refresh rate. **Resolution and scale persist correctly;
refresh rate does not persist as requested.** Given the deadline, recording
this as a disclosed, scoped defect rather than dispatching another fix
cycle — it needs its own small investigation in `regolith-displayd`'s mode
matching, not urgent enough to displace the remaining schedule.

## Multi-display and mixed DPI — attempted honestly, still open

`-device virtio-vga,max_outputs=2` created a second DRM connector, but VNC
only backs head 0, so the second output stays disconnected and never
reaches Sway or displayd. `apply` against a second output correctly fails
with `unknown COSMIC output`. Getting a second real, configurable output
under QEMU would need something like `-display egl-headless` with two
virtio-gpu devices, or two independent VNC displays — untried, unbudgeted
against the remaining schedule.

"Mixed DPI" in the sense the criterion means (different scales on different
outputs simultaneously) was not exercised — only sequential different
scales on the same single output.

## Verdict against the real numbered matrix

Quoting `09_Final_Docs/2026-08-12-proposal-requirement-matrix.md` directly,
per `09_Final_Docs/2026-08-21-criterion-numbering-authority-note.md`:

**Criterion 3 — "Single display plus multi-display hotplug, mixed DPI,
persistence."** **Stays `Partial`.** The row is a conjunction. Single
display and persistence are now genuinely proven; multi-display hotplug on
a real configurable second output and true simultaneous mixed DPI are not.
Promoting this row would mean claiming the half that wasn't tested.

**Criterion 7 — "Supported display/input settings persist across
reboot."** **Stays `Partial`, not promoted**, for two reasons, matching the
verifying agent's own conservative read: the row is display **and** input,
and input-settings persistence was not exercised this run; and what
persisted for display was correct for resolution and scale but
**demonstrably wrong for refresh rate** — "settings persist" isn't
cleanly true when one of the settings persists incorrectly.

This is real, new, positive evidence — the strongest this project has for
either criterion. It also directly contradicts the gist's prior `Met`
claim for Criterion 7 (from the 2026-08-17 combined run, which never tested
a specific requested refresh rate). Corrected: gist row 7 to `Partial`,
published ledger **6/12 -> 5/12**. Under-claiming would have cost less; the
project's standing rule this week has been to correct in whichever
direction the evidence actually points.

## Recommendation for future QEMU display work in this project

Standardize on `-device virtio-vga -vnc 127.0.0.1:<port>` (or equivalent)
whenever a proof needs a genuinely enabled output, not `-display none`.
Reserve `-display none` for proofs that are only about session/service
health, where the explicit "no pixels, headless" disclosure this project
has used all session remains the right caveat.
