# Native COSMIC display mutation boundary

Date: 2026-08-10  
Environment: disposable native COSMIC seat in the QEMU qualification guest

## What was tested

- Started the native COSMIC entrypoint without the Regolith Sway wrapper.
- Confirmed that `cosmic-session` and `cosmic-comp` were running.
- Captured the native session environment and `cosmic-randr list` output.
- Attempted a reversible `cosmic-randr mode` change from the available
  `1280x800@74.994Hz` mode to `1024x768@60.004Hz`.

## Result

The command returned exit status `0`, but the active mode remained
`1280x800@74.994Hz` and the COSMIC output-profile SHA-256 stayed unchanged.
This is a no-op/negative result, not proof that native COSMIC display mutation
or persistence works. It does not close the native Settings-panel or native
`cosmic-comp` display-mutation gates.

The detailed before/after output, return codes, profile snapshots, and process
evidence remain in the private vault proof bundle. They are intentionally not
copied into this lightweight public repository.

## Restoration

The original greeter configuration was restored to its recorded checksum, and
the disposable guest was rebooted after restoration. No source branch,
package, or frozen Regolith tuple was changed.

## Proposal boundary

Native COSMIC session startup is proven as a separate runtime subgate. Native
display mutation, direct Settings-panel coverage, physical/equivalent
multi-display, hotplug, and mixed-DPI persistence remain `Partial`/`Open`.
