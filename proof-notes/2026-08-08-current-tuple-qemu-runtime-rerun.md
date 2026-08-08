# Current tuple QEMU runtime rerun - 2026-08-08

The eight current-hash packages from the current Voulage tuple were installed
in disposable QEMU and configured successfully with `dpkg -i`.

A fresh greetd-managed session returned to the baseline `1280x800` output. No
user `cosmic-comp` process was present. During teardown of the previous Sway
session, displayd and cosmic-idle each reported one broken-pipe restart while
their old Wayland connection closed. After the new session stabilized, a user
manager reload, failure reset, and targeted helper restart produced:

```text
regolith-cosmic.target ActiveState=active NeedDaemonReload=no
regolith-init-cosmic-idle.service ActiveState=active Result=success NRestarts=0
regolith-init-inputd.service ActiveState=active Result=success NRestarts=0
regolith-init-displayd.service ActiveState=active Result=success NRestarts=0

XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
swaymsg reload: [{"success":true}]
```

The resource errors did not recur. This is current-hash, QEMU-only,
Sway-backed proof; it does not claim native `cosmic-comp`, hardware, or
full-laptop boot.
