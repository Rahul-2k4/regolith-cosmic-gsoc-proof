# Current mentor installer proof - 2026-08-24

## Scope

This note records the exact current seven-package bundle being exercised
through `scripts/install-real-system.sh`. It is disposable Pop!_OS 24.04
QEMU proof, not physical-hardware proof.

Bundle directory:

```text
artifacts/mentor-seven-package-bundle/
```

The committed `artifacts/mentor-test-2026-08-18.sha256` manifest validated all
seven package hashes before installation. The displayd entry is
`regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb`, built from source
commit `575004619ae0aafef627ba87493e87546da15534`, with SHA-256
`413d793b3d073f8e00934206cb5b41477850699a84c6b8510dc34f249afb073a`.

## Commands and results

Run from a clone of the public proof repository:

```sh
./scripts/install-real-system.sh install \
  --package-dir artifacts/mentor-seven-package-bundle --dry-run
```

Result: host compatibility, dependency preflight, package validation, and
the non-mutating seven-package dry-run all passed.

The real transaction was then run with the same command without `--dry-run`.
It recorded a baseline under `/var/lib/regolith-cosmic-gsoc`, installed the
seven pinned packages in one APT transaction, and ended with:

```text
PASS: installed exactly 7 packages
```

The final installer uses a private `/tmp/install-real-system.*` staging path,
then grants only the invoking user and the APT `_apt` group access needed for
the local package read. The QEMU run completed without APT's
`Download is performed unsandboxed as root` warning.

After a reboot, the greeter was logged into through the QEMU host monitor and
the verifier was run with the graphical session environment:

```sh
XDG_RUNTIME_DIR=/run/user/1000 \
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway \
./scripts/install-real-system.sh verify
```

Observed results:

- COSMIC desktop entry present.
- `regolith-cosmic.target` active.
- `regolith-init-inputd.service` active.
- `regolith-init-displayd.service` active.
- `regolith-gnome.target` inactive.
- `systemctl --user --failed --no-legend` empty.
- `dpkg --audit` empty.
- `regolith-displayd` installed as `0.3.4-1-1regolith-resolute`.

Real hardware, multi-display behavior, and final maintainer/archive
publication remain separate tests. This note does not claim them.
