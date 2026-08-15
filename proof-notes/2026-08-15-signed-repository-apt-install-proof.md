# Signed local-repository install proof - Ubuntu 26.04

Date: 2026-08-15

## Result

A fresh `ubuntu:26.04` container installed `regolith-session-cosmic` from a
local GPG-signed repository plus the Regolith upstream archive. The repository
used the modern `signed-by` keyring configuration. No `--force`, trust bypass,
or manual dependency override was used.

The final install returned `EXIT_CODE=0`. A second idempotent install also
returned zero. The full logs contained no `E:` errors, `NO_PUBKEY` messages,
or untrusted-repository warnings. Independent `dpkg -l` checks showed the
COSMIC session packages in the `ii` state after installation.

The local pool contained the complete Ubuntu/Resolute dependency closure,
including `cosmic-session`, `cosmic-comp`, `cosmic-settings-daemon`,
`cosmic-greeter`, `cosmic-greeter-daemon`, `cosmic-randr`,
`cosmic-app-library`, `sway-regolith`, and the required Regolith/COSMIC
support packages.

## What this proves

- The literal Ubuntu 26.04 package-install path from the proposal resolves and
  configures cleanly against a signed repository.
- Package metadata, dependency closure, repository signing, and idempotent
  installation work together in a disposable clean environment.

## Boundaries

This is a local demonstration repository. It is not publication to Regolith's
real archive and does not use Regolith's release signing identity. Canonical
Voulage publication, maintainer approval, and final release disposition remain
open. Debian Trixie was not re-run against this signed repository.

This proof strengthens criterion 10 but does not mark it fully met. It also
does not replace graphical QEMU, hardware-equivalent display, input, or
Settings-panel validation.
