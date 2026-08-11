# Final target-split second cold-login proof - 2026-08-12

The final target-split Resolute package tuple was installed in a second fresh
copy-on-write QEMU overlay from the qualification image. The base image was
not modified.

The independent run reproduced the first result:

- `INSTALL_RC=0`.
- Cold reboot completed and greetd returned successful session-start replies.
- `regolith-cosmic.target` was active.
- `regolith-gnome.target` was inactive.
- `regolith-init-inputd.service` and `regolith-init-displayd.service` were
  active and running.
- `dpkg --audit` produced no output.
- `Mod4+Space` launched ilia.
- `Mod4+2` and `Mod4+1` switched workspaces and returned to workspace 1.

This is a second QEMU-only confirmation of the package-to-graphical-login
integration. It does not prove native hardware behavior, the full transitive
APT graph, signed publication, or mentor acceptance.

The first-run package metadata and integration note is:

`https://github.com/Rahul-2k4/regolith-cosmic-gsoc-proof/blob/main/proof-notes/2026-08-12-direct-session-package-audit.md`
