# Installed inputd live-handler rerun - 2026-07-27

This QEMU rerun used the installed `regolith-inputd 0.4.1` in the COSMIC
session. The session exported
`XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`.

The keyboard/input-source helper changed the COSMIC XKB configuration from
`us`, empty variant, repeat `600/25` to `fr`, `azerty`, repeat `540/31`.
Sway then reported the French layout and the new repeat values. The original
configuration was restored and Sway returned to English (US) with `600/25`.

The mouse helper changed COSMIC natural scrolling to false. Sway reported
`natural_scroll: disabled`. The value was restored to true and Sway reported
`natural_scroll: enabled` again.

No failed user units appeared during the changes. The legacy inputd,
displayd, and kanshi helper units remained runtime-masked and inactive.

This proves the installed QEMU live-session scope. It does not prove a fresh
greeter login, a physical touchpad, hardware behavior, or the complete final
package matrix.
