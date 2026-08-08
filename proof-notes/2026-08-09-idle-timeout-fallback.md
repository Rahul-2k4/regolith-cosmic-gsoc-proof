# Fallback idle timeout - 2026-08-09

The Sway-backed session uses `swayidle` with `gtklock` when native
`cosmic-idle` is not selected. A disposable three-second timeout harness using
the same locker command produced the gtklock password surface in QEMU. The
desktop was unlocked and the temporary harness was stopped; no user units were
failed afterward.

This proves the fallback timeout-to-lock path. It does not prove native
`cosmic-idle`, logind lock-state semantics, or the exact five-minute shipped
timeout.
