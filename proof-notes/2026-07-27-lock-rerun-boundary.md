# Lock path rerun boundary - 2026-07-27

The active session still uses `swayidle + gtklock`. An explicit lock request
launched gtklock and no failed user units appeared. In the nested QEMU session,
the logind `LockedHint` did not become `yes`, and an SSH-side unlock request did
not terminate the standalone gtklock process. The temporary process was
cleaned up explicitly.

This keeps the lock path provisional. It is not a complete lock, unlock,
timeout, and recovery proof, and does not justify replacing the path with
`cosmic-idle` yet.
