# Target-owned helper lifecycle QEMU proof, v2

This is a disposable Ubuntu Resolute QEMU result for the combined source
branch and the rebuilt inputd/displayd packages.

## Source and packages

- `regolith-session` combined source: [`22e43c5`](https://github.com/Rahul-2k4/regolith-session/commit/22e43c5)
- `regolith-inputd` target ownership source: [`3039744`](https://github.com/Rahul-2k4/regolith-inputd/commit/3039744ce49c6981108ddb169ed741d94edb214d)
- `regolith-displayd` target ownership source: [`7629a7e`](https://github.com/Rahul-2k4/regolith-displayd/commit/7629a7e22bbd22b13316b72b2eaecb5b00cb70c4)
- session branch: [`cosmic-closure-combined-20260811`](https://github.com/Rahul-2k4/regolith-session/tree/rahul/cosmic-closure-combined-20260811)
- package versions: `regolith-session 1.2.0-1ubuntu1-1-1regolith-resolute`, `regolith-inputd 0.4.1-2-1regolith-resolute`, `regolith-displayd 0.3.4-1-1regolith-resolute`

## Passed

- `dpkg -i` completed with `INSTALL_RC=0`.
- The GNOME target package replaced the old Sway-owned parent drop-in without
  a dpkg collision.
- Reboot completed and greetd returned `START_REPLY success`.
- `cosmic-session` and Sway ran with
  `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`.
- `regolith-cosmic.target` was active and listed inputd, displayd, and the
  COSMIC idle helper in its Wants graph.
- Both daemon services were `active (running)` with `ExecMainStatus=0`.
- `dpkg --audit` was empty after install and reboot.
- The overlay, staging files, monitor socket, and QEMU process were cleaned;
  the backing image was not modified.

## Still open

The direct `swaymsg exit` attempt returned an IPC receive error. Sway stopped,
and the COSMIC target and helper services became inactive, but the
`cosmic-session` parent remained. This proves target-owned helper startup, not
clean parent-session teardown.

The follow-up [parent lifecycle diagnostic](2026-08-11-parent-lifecycle-diagnostic-qemu-proof.md)
captured process ancestry and a bounded user-journal sample after the same exit
path. It did not justify changing the Regolith wrapper to kill the outer
session manager.

Voulage still reports existing Lintian warnings, and its temporary apt-source
cleanup needs an interactive sudo prompt. The package build itself returned
zero.

The strict proposal headline stays `62-68%` and `4/12` fully met. This is
QEMU-only evidence and does not claim hardware, native `cosmic-comp` display
mutation, signing, publication, or mentor acceptance.
