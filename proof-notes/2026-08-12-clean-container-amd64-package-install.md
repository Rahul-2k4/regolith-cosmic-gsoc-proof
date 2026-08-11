# Clean-container amd64 package install - 2026-08-12

## Result

The current staged package tuple installed into disposable amd64 containers
without modifying the host, laptop, QEMU base image, or a release repository.

### Ubuntu 26.04 / Resolute

```text
APT_UPDATE_RC=0
APT_INSTALL_RC=0
DPKG_AUDIT=EMPTY
cosmic-session              1.0.0-1-1regolith-resolute
cosmic-settings-daemon     0.1.0-1-1regolith-resolute
regolith-displayd          0.3.4-1regolith-resolute
regolith-inputd            0.4.1-1-1regolith-resolute
regolith-session-common    1.2.0-1ubuntu1-1-1regolith-resolute
regolith-session-cosmic    1.2.0-1ubuntu1-1-1regolith-resolute
```

### Debian Trixie

```text
APT_UPDATE_RC=0
APT_INSTALL_RC=0
DPKG_AUDIT=EMPTY
cosmic-session              1.0.0-1-1regolith-resolute
cosmic-settings-daemon     0.1.0-1-1regolith-resolute
regolith-displayd          0.3.4-1-1regolith-trixie
regolith-inputd            0.4.1-1-1regolith-trixie
regolith-session-common    1.2.0-1ubuntu1-1regolith-trixie
regolith-session-cosmic    1.2.0-1ubuntu1-1regolith-trixie
```

No installation errors were emitted in either container.

## Method

Docker Engine `29.4.0` ran `ubuntu:26.04` and `debian:trixie` with
`--platform linux/amd64`. The staged package directories were mounted
read-only. A temporary `policy-rc.d` returned `101` so package installation
could not start services inside the disposable container. Each run enabled the
Regolith unstable archive, ran `apt-get update`, installed the exact staged
tuple with `apt-get install --no-install-recommends`, then checked
`dpkg --audit` and queried the six target packages.

## Boundary

This closes a real filesystem-install subgate for the staged tuple. It does
not claim a graphical login, native `cosmic-comp` display mutation, hardware
coverage, signing, publication, or upstream merge.

The Trixie run used the available local COSMIC package pool, whose two COSMIC
packages retain the `regolith-resolute` package suffix. Therefore the Trixie
result is not a claim that a canonical Trixie COSMIC package publication is
ready; a Trixie-native COSMIC package matrix remains a release gate.

