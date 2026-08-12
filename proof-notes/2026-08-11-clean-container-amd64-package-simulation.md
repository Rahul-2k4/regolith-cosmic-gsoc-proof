# Clean-container amd64 package simulation - 2026-08-11

## Result

The current staged session tuple resolves successfully in disposable
`amd64` containers for both target distributions:

```text
Ubuntu 26.04 / Resolute: APT_UPDATE_RC=0, APT_SIMULATION_RC=0
Debian Trixie:             APT_UPDATE_RC=0, APT_SIMULATION_RC=0
```

No `E:` or `Err:` lines were emitted by either solver run.

The simulation selected only these GNOME-related packages:

```text
gnome-keyring
gnome-themes-extra
gnome-themes-extra-data
```

The run did not select `gnome-session-bin`, `gnome-settings-daemon`,
`gnome-control-center`, `mutter`, or `nautilus`.

## Inputs and method

- Docker Engine `29.4.0`.
- Images: `ubuntu:26.04` and `debian:trixie`.
- Both runs used `--platform linux/amd64`; the staged Regolith artifacts are
  amd64 packages and the Mac host otherwise selects an ARM64 image.
- Package inputs were copied from the laptop's current Voulage publication
  directories into disposable local staging directories. The staging copy was
  not used as a release source.
- The Regolith unstable archive was enabled as a trusted test source only for
  this disposable solver run.
- The package set included `regolith-session-common`,
  `regolith-session-cosmic`, `regolith-displayd`, `regolith-inputd`,
  `regolith-sway-root-config`, `regolith-sway-dbus-activation`,
  `regolith-wm-config`, `cosmic-session`, and
  `cosmic-settings-daemon`.
- The command used `apt-get -s --no-install-recommends install`, so it tested
  dependency resolution without installing packages or modifying a persistent
  VM, host, or release repository.

## Boundary

This is positive transitive package-graph evidence for the current staged
tuple. It is not a claim of a clean filesystem installation, graphical login,
native `cosmic-comp` display mutation, hardware coverage, package signing,
publication, or upstream merge. Those remain separate proof gates.

## Reproduction shape

Run the exact package set inside each container with the matching `amd64`
platform:

```bash
docker run --rm --platform linux/amd64 \
  -v "$SESSION_PACKAGES:/session:ro" \
  -v "$BASE_PACKAGES:/base:ro" \
  -v "$UNSTABLE_PACKAGES:/unstable:ro" \
  -v "$COSMIC_PACKAGES:/cosmic:ro" \
  ubuntu:26.04 bash
```

Inside the container, add the target-distro Regolith archive, run
`apt-get update`, then run `apt-get -s --no-install-recommends install` over
the nine package inputs listed above. Repeat with `debian:trixie` and its
matching Trixie package directories. Record both exit codes and inspect the
solver log for the GNOME allowlist and forbidden session packages above.

