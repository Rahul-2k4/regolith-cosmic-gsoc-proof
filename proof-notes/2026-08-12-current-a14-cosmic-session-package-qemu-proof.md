# Current `cosmic-session` package QEMU proof

Date: 2026-08-12
Status: package install and cold-reboot proof passed; graphical login not
claimed

## Exact provenance

- Source: [`a14abe3`](https://github.com/Rahul-2k4/cosmic-session/commit/a14abe378a513c6c5499b52b0d4d1afe50a41644)
- Voulage builder: [`49f26e1`](https://github.com/Rahul-2k4/voulage/commit/49f26e1485c4cb1c7e961b2a0939ab623ac0db8e)
- Package version: `1.0.0-1-1regolith-resolute`
- Package SHA-256: `cd9693b28fc1e59f66f4a116634a79489ed008af9fc7ca070fbfdd3df0131509`
- Installed `/usr/bin/cosmic-session` SHA-256: `c233f137425fa6fe4f54fbc05cec46be422fe39683822bbe18acf2c635799bb0`

The package was built through Voulage's local-build path with the reviewed
local-build apt-dependency skip gate. Cargo dependencies were vendored and
the release binary compiled offline from the pinned source.

## Disposable QEMU result

The package was installed by itself over the existing package in a qcow2
overlay backed by the qualification image. The canonical image was not
modified.

- QEMU launched and guest SSH became ready.
- `dpkg -i` returned `0`.
- `cosmic-session` reported version `1.0.0-1-1regolith-resolute`.
- `dpkg --audit` was empty after installation and after reboot.
- The installed binary hash matched the build candidate before and after
  cold reboot: `c233f137425fa6fe4f54fbc05cec46be422fe39683822bbe18acf2c635799bb0`.
- The overlay, staging directory, monitor socket, and temporary log were
  removed by the harness.

## Boundary

This proves current-source packaging, installation, binary identity, and
cold-reboot integrity. The run did not perform a graphical greeter login, so
it does not prove the current `a14abe3` package's complete session lifecycle.
The historical source/package runtime replay remains separate. The strict
proposal status stays `62-68%` with `4/12` criteria fully met.
