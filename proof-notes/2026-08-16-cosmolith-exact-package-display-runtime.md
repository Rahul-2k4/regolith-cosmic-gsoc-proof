# Exact COSMolith package display runtime proof

Date: 2026-08-16

This is a sanitized QEMU proof for the current COSMolith package in the
Sway-backed COSMIC session. It covers one virtual output only.

## Exact source and artifact

- COSMolith source: [`cd1cbb0`](https://github.com/Rahul-2k4/cosmolith/commit/cd1cbb031566e96dd6d73ce22029b970a012ee42)
- Voulage package-model change: [`8d72149`](https://github.com/Rahul-2k4/voulage/commit/8d7214915bda6c2672964cb22f03889865b92ce1)
- Voulage verifier commit: [`e9ab3361`](https://github.com/Rahul-2k4/voulage/commit/e9ab3361)
- Package: `cosmolith 0.1.0-1-1regolith-resolute amd64`
- Package SHA-256: `956c79413c3cde5a53bbd5d9473bc9370cb4d0bbd4a06ed89b2717ce81d2eede`
- Installed executable SHA-256: `5b9439c294c159ab43f39a200a236caeaf2febacc00256df94de4b31d2053c6f`

## Reproduction

1. Log into the disposable QEMU COSMIC session.
2. Export the live `WAYLAND_DISPLAY`, `XDG_RUNTIME_DIR`,
   `DBUS_SESSION_BUS_ADDRESS`, and `XDG_CURRENT_DESKTOP` values. Derive the
   current Sway IPC socket from `XDG_RUNTIME_DIR`.
3. Run:

   ```sh
   cosmic-randr mode Virtual-1 1280 800 --refresh 74.994
   cosmic-randr mode Virtual-1 1024 768 --refresh 60.004
   ```

4. Confirm the generated profile contains `1024x768@60.004Hz`.
5. Cold-reset the guest, complete the graphical login, and wait for
   `cosmolith` to appear under `regolith-session-cosmic-runtime`.
6. Confirm `swaymsg -t get_outputs` reports `Virtual-1` at `1024x768` and the
   generated profile still contains `1024x768@60.004Hz`.

## Result

The exact package was installed, the output mutation completed, the generated
profile was updated, and the selected mode was still active after reset and
graphical login. The COSMIC target and display/input helper units were active;
`dpkg --audit` was empty.

The verifier must export the graphical session variables and wait briefly for
the wrapper-owned COSMolith process after login. An SSH shell does not inherit
the Wayland environment, and the wrapper starts COSMolith after compositor
readiness.

This result is distinct from the older displayd-only storage-pass/apply-fail
tuple, where Kanshi was inactive. Here the generated Sway directive is loaded
by the Sway-backed compositor during the next session start.

## Limits

This is QEMU-only, single-output, Sway-backed evidence. It does not prove
native `cosmic-comp`, the COSMIC Settings GUI, physical hardware,
multi-display/hotplug/mixed-DPI behavior, signed publication, or upstream
acceptance. The strict proposal status remains `62-68%` and `4/12` criteria
fully met.
