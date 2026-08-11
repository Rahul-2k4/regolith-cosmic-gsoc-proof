# Current inputd package and QEMU reboot proof

Date: 2026-08-12

## Source and build

- Repository: [`regolith-inputd`](https://github.com/Rahul-2k4/regolith-inputd)
- Branch: [`rahul/inputd-touchpad-lintian-reconciled-20260811`](https://github.com/Rahul-2k4/regolith-inputd/tree/rahul/inputd-touchpad-lintian-reconciled-20260811)
- Source commit: [`e641b43`](https://github.com/Rahul-2k4/regolith-inputd/commit/e641b434c76c70e9a21e492adea577607e096d03)
- Package: `regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb`
- Ubuntu Resolute Voulage binary build exit code: `0`
- Ubuntu Resolute Lintian exit code: `0`

The Debian Trixie binary build also exited `0`; its local Lintian run reported
only `bad-distribution-in-changes-file` for the locally generated `trixie`
distribution tag. The source verification on Linux passed `cargo test
--no-default-features --features cosmic`, `cargo test --all-features`, and
`cargo fmt --check`.
The feature-specific suite ran 46 tests; the all-feature suite ran 49 tests.

## Disposable QEMU proof

The package was installed beside the revised session tuple in a disposable
overlay based on the retained QEMU image. `dpkg -i` returned `0`. The package
payload hash and installed `/usr/bin/regolith-inputd` hash both were:

```text
278043ab0bd9775f25490fe2a764cb5adc958047ef975a56cf85f8659e12a464
```

After a cold reboot, SSH returned on the second bounded attempt. The installed
inputd version remained `0.4.1-2-1regolith-resolute`, the binary hash still
matched, and `dpkg --audit` produced no output. The GNOME target file remained
owned by `regolith-session-gnome-targets`. The overlay, monitor socket, and
QEMU process were removed; the canonical base disk was not modified.

## Boundary

This proves current-head package/build/reboot integrity. It does not claim a
graphical login from this run, physical input behavior, active-layout switching,
or COSMIC reverse-sync. The source still documents those as open input gaps.
