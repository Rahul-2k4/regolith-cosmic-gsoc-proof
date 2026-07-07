# regolith-displayd display persistence monitoring research - 2026-07-04

## Mentor prompt

Soumya asked whether the COSMIC display persistence idea can happen in `regolith-displayd`, and whether `cosmolith` makes more sense.

Target model:

- COSMIC Settings / `cosmic-randr` applies display changes through `wlr-output-management`.
- Regolith watches the resulting output state.
- Regolith stores a persistence profile from observed output state.
- Prefer Wayland / wlr protocol monitoring if practical.
- Sway IPC output monitoring is acceptable fallback.

## Source findings

### COSMIC apply path

From COSMIC source:

- `cosmic-settings` display page delegates changes to `cosmic-randr`.
- `cosmic-randr` uses Wayland output management: `wlr-output-management-unstable-v1`.
- COSMIC also layers its own output-management extension through `cosmic-protocols`.
- `cosmic-comp` writes output config after successful apply through `write_outputs(...)`.

Useful source links:

- https://github.com/pop-os/cosmic-settings/blob/master/cosmic-settings/src/pages/display/mod.rs
- https://github.com/pop-os/cosmic-randr/blob/master/lib/src/lib.rs
- https://github.com/pop-os/cosmic-randr/blob/master/lib/src/output_manager.rs
- https://github.com/pop-os/cosmic-comp/blob/master/src/wayland/handlers/output_configuration.rs

### regolith-displayd current role

Upstream repo:

- https://github.com/regolith-linux/regolith-displayd

Repository description says it is a daemon providing `gnome-control-center` DisplayConfig DBus bindings for Sway.

Current architecture:

- Rust daemon.
- Exposes `org.gnome.Mutter.DisplayConfig`.
- Uses `swayipc-async`.
- Gets current output state from `sway_connection.get_outputs()`.
- Writes kanshi profile files when `ApplyMonitorsConfig` is called over DBus.
- Reloads kanshi after writing profile.
- Has `DisplayManager::watch_changes(...)`, which polls Sway output state every 700ms, updates in-memory monitor/logical-monitor state, and emits `MonitorsChanged`.

Important source points:

- `src/main.rs`: starts `DisplayServer`, creates Sway IPC connection, spawns `DisplayManager::watch_changes(...)`.
- `src/lib.rs`: `apply_monitors_config(...)` writes kanshi profile content.
- `src/lib.rs`: `watch_changes(...)` detects output/layout changes from Sway output state.
- `data/regolith-init-displayd.service`: displayd starts before/requires kanshi in the existing Regolith path.

## Gap

`regolith-displayd` already has two separate halves:

1. DBus apply path writes kanshi persistence profile.
2. Watcher path notices Sway output changes and emits DBus signal.

The missing COSMIC-oriented behavior is connecting those halves:

> when an external display change is observed, write or update the persistence profile from the observed output state.

That external change could come from COSMIC Settings / `cosmic-randr` if the session is compatible with the same observed output state.

## Candidate implementation direction

### First choice: `regolith-displayd`

This currently looks like the right first implementation target.

Reasons:

- It already owns Regolith display DBus behavior.
- It already knows how to serialize display state into kanshi profile files.
- It already watches output/logical-monitor changes.
- Adding external-change persistence is a small, local extension compared with creating or reviving another daemon.
- This matches mentor direction to keep existing components interoperable before adding new programs.

Likely change shape:

1. Add a helper that converts current `DisplayManager` monitor/logical-monitor state into the same kanshi profile format used by `ApplyMonitorsConfig`.
2. Call it from `watch_changes(...)` only when the observed logical output state changes.
3. Avoid rewriting during initial startup baseline unless explicitly intended.
4. Avoid infinite loops with kanshi reloads by debouncing or checking content hash before write.
5. Keep COSMIC/Sway behavior gated by session/backend if needed.

### Fallback: `cosmolith`

Use `cosmolith` only if `regolith-displayd` cannot cleanly own this.

Possible reasons to move to `cosmolith`:

- Need a pure Wayland/wlr output-management event client instead of Sway IPC.
- `regolith-displayd` becomes too tied to GNOME DisplayConfig compatibility.
- Persistence format needs broader COSMIC-specific state that displayd cannot represent.

For now, `cosmolith` is not first choice.

Subagent caveat:

- Existing `cosmolith` display persistence work already appears closer to a native session watcher model.
- That makes `cosmolith` a useful reference for implementation shape.
- It does not override the current mentor preference to first see whether existing Regolith components can become interoperable.
- Decision stays: inspect/try `regolith-displayd` first, then justify `cosmolith` only with a concrete fit gap.

## Monitoring options

### Preferred: Wayland / wlr output-management

Pros:

- Matches COSMIC apply protocol.
- Avoids Sway-specific assumptions.
- Can be built from the same model `cosmic-randr` already uses.

Cons:

- More new code in Regolith if `regolith-displayd` currently only depends on Sway IPC.
- Need to confirm whether the relevant protocol events expose enough final state for kanshi profile generation.
- Need a careful event model so we do not accidentally treat test/failed configs as persisted state.

### Fallback: Sway IPC output events or polling

Pros:

- `regolith-displayd` already uses `swayipc-async`.
- Current code already polls output state and detects logical changes.
- Fastest path to proof in the current Regolith/Sway testbed.

Cons:

- Sway-specific.
- Does not prove a future pure COSMIC compositor path.
- Polling every 700ms is less elegant than event subscription.

## Runtime proof still needed

Blocked in this session because SSH to laptop timed out:

```text
ssh: connect to host <test-host-ip> port 22: Operation timed out
```

Next runtime proof when laptop is reachable:

1. Start QEMU qualification VM.
2. Capture current session identity and output state.
3. Start `swaymsg -t subscribe '["output"]'` or equivalent event monitor.
4. Apply reversible display change through `cosmic-randr`.
5. Confirm monitor sees output change.
6. Capture resulting Sway output state.
7. Restore original display state.
8. For true COSMIC persistence question, boot/login a real `cosmic.desktop` / `cosmic-comp` session and verify whether `~/.local/state/cosmic-comp/outputs.ron` changes and survives restart.

## Current conclusion

Use `regolith-displayd` as first target.

Do source proof first:

- refactor profile serialization into reusable helper
- add observed-output persistence path behind conservative guard
- test with synthetic monitor/logical-monitor state if possible

Then runtime proof:

- prove Sway IPC detects `cosmic-randr` output changes
- prove profile file is written once and not looped
- only then evaluate whether a Wayland/wlr monitor client is worth adding

## Question to answer before implementation

Is the target persistence artifact still kanshi profile files, or should Regolith write Sway output config directly for COSMIC sessions?

Current `regolith-displayd` writes kanshi profiles. Existing `cosmolith` work may write Sway config fragments instead. This needs one concrete decision before code changes.
