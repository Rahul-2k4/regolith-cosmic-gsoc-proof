# QEMU live manager and Sway socket repair - 2026-08-08

After package replacement, the user manager had stale unit definitions and
inputd/displayd had inherited a dead Sway IPC socket. The repair reloaded the
user manager, refreshed the session environment, and restarted only the two
affected helpers.

Verified result:

```text
regolith-cosmic.target NeedDaemonReload=no
regolith-init-cosmic-idle.service NeedDaemonReload=no
regolith-init-inputd.service NeedDaemonReload=no
regolith-init-displayd.service NeedDaemonReload=no

regolith-init-inputd.service ActiveState=active Result=success NRestarts=0
regolith-init-displayd.service ActiveState=active Result=success NRestarts=0

regolith-init-inputd.service uses the live Sway IPC socket
regolith-init-displayd.service uses the live Sway IPC socket
swaymsg reload: [{"success":true}]
recent helper/config error scan: no matches
```

This confirms the Sway-backed COSMIC session path without a user
`cosmic-comp`. It is a live-session repair, not a fresh reboot/login or
native-compositor proof.
