# Combined display and input cold-login proof - 2026-08-16

## Result

The patched COSMIC package tuple was installed in a disposable QEMU overlay.
After a cold reset and graphical login, both display and input state persisted:

- Sway IPC reported the single virtual output at `1024x768@60.004Hz`.
- Complete XKB input state remained French AZERTY with repeat `550/32`.

The `regolith-cosmic.target` path was active, with target-owned displayd,
inputd, and kanshi helper units active after login. The packaged `cosmolith`
watcher was explicitly started for this test to observe the persisted XKB
state; it is not target-owned.

## Boundary

This is QEMU-only, single-output evidence. It does not establish hardware,
multi-display or hotplug coverage, native `cosmic-comp`, physical input
coverage, or Settings GUI coverage.

The strict work-product status remains **62-68%** and **4/12 criteria fully
met**. Criterion 7 remains partial because the broader display and hardware
matrix is still open.
