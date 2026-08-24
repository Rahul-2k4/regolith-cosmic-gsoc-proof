# 2026-08-23 displayd COSMIC Wayland apply package/runtime proof

Exact source commit: `48025e352dc107de90067dccb33e5dc280ade8f7`.

The offline package `regolith-displayd_0.3.4-1_amd64.deb` was rebuilt with
`CARGO_NET_OFFLINE=true VENDOR=1 dpkg-buildpackage -us -uc -b -nc` and has
SHA-256
`4d410cc022ecdcd497ce48d94e05ba4464dacddb75ea15dd57d033334ec4e601`.
The source suite passed 66 library tests.

The package was installed into the disposable QEMU COSMIC overlay. The
installed package reported `install ok installed`; `regolith-init-displayd`
was active after restart; the D-Bus interface exposed
`ApplyMonitorsConfig`/`GetCurrentState`; and verify/apply D-Bus calls returned
exit code 0 against the live `HEADLESS-1` compositor output. No displayd
restart/panic occurred, and the user failed-unit list plus `dpkg --audit` were
empty.

This is package/runtime D-Bus proof only. The headless output has no real mode
list, so it does not claim native mode/scale mutation, multi-display, hotplug,
hardware persistence, or refresh-rate correctness.
