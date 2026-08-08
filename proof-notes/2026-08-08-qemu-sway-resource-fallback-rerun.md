# QEMU Sway resource fallback rerun - 2026-08-08

This rerun covers the reported configuration failure in the Regolith
Sway-backed COSMIC path. No user `cosmic-comp` process is required.

Source: `Rahul-2k4/regolith-wm-config`, branch
`rahul/cosmic-kanshi-owner-wm-config-resource-fallbacks-20260808`, commit
`10225c056ee3ae15ab5745aba5a86ba611801ed5`.

The fix adds literal `"#002b36"` fallbacks for the four Sway child-border
resource lookups and a canonical Ilia stylesheet fallback. The focused test,
shell syntax check, and `git diff --check` pass.

QEMU result:

```text
user cosmic-comp count: 0
swaymsg reload: [{"success":true}]
loaded config: /etc/regolith/sway/config
```

The latest helper/config journal scan contains no `child_border`,
`ilia.stylesheet`, invalid-color, or reload errors. This is QEMU/Sway-backed
proof only; it does not claim native COSMIC compositor mutation or hardware
behavior.
