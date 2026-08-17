# Displayd COSMIC Kanshi guard runtime - 2026-08-18

The accepted `regolith-displayd` COSMIC guard was packaged and exercised with
the current five-package COSMIC tuple in a disposable Pop!_OS QEMU overlay.

## Inputs

- `regolith-session-cosmic`: Voulage package SHA `8e3559e8...`
- `regolith-inputd`: clean forward-XKB package SHA `5f2a2806...`
- `regolith-displayd`: source `91bdd26`; Voulage model `616d9f16`; package
  SHA `1b8e348925497574163f0fd627523416b64cb7885451f5930a07c952a2b930f7`
- `cosmolith`: package SHA `ad5af5ed...`
- `cosmic-settings`: package SHA `5459b91e...`

## Result

Package setup completed in the guest. After reboot, greetd authentication
returned success and `regolith-session-cosmic-launch` returned success.
The runner reported `RUNTIME_COMMANDS_COMPLETED=1`.

The run used a child qcow2 overlay. The protected base image was unchanged;
the child overlay, temporary credentials, sockets, logs, and staging files were
removed during cleanup.

This run confirms installation and COSMIC session startup for the updated
displayd package. It does not claim physical hardware or multi-output behavior.
