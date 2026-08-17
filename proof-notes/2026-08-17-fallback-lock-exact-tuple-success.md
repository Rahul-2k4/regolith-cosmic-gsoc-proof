# Fallback idle-to-lock exact-tuple QEMU proof

This disposable Pop!_OS COSMIC QEMU run tested Regolith's supported Sway
fallback path. A three-second `swayidle -w timeout 3 gtklock` harness reached
`LOCK_SEEN=1`; the captured framebuffer shows the gtklock password surface.

Cleanup removed the temporary locker. The shipped 300-second `swayidle`
process remained. `dpkg --audit` returned no output.

- [Harness log](../artifacts/fallback-lock-exact-tuple-20260817.log)
- [Lock screenshot](../artifacts/fallback-lock-exact-tuple-20260817.png)

One unrelated pre-existing user unit was reported failed:
`app-polkit-mate-authentication-agent-1@autostart.service`. This note claims
the fallback lock path only. Native `cosmic-idle`, logind idle hints, hardware
idle behavior, and full shutdown remain open.
