# Mentor real-system installer

Date: 2026-08-18

## Result

The public proof branch now has a guarded installer for the exact seven-package
Regolith COSMIC test tuple. It supports remote prerelease downloads or a local
package directory, verifies SHA-256 and Debian package metadata, checks host
and dependency compatibility, records a rollback baseline, and installs all
seven packages in one APT transaction.

The script does not reboot, stop the display manager, change the default
session, or store credentials. User-supplied packages are copied into a
private temporary directory before validation and privileged installation.

## Files

- `scripts/install-real-system.sh`
- `tests/install-real-system-contract.sh`
- `artifacts/mentor-test-2026-08-18.sha256`
- `docs/INSTALL.md`

## Verification

Implementation commits:

- `dda33dc`: initial guarded installer and contract suite
- `5ac3894`: runtime-state, dependency, URL, and baseline fixes
- `c9743c6`: private artifact staging and transaction-scoped rollback

Independent checks:

```text
bash -n scripts/install-real-system.sh tests/install-real-system-contract.sh
PASS: install-real-system contract
git diff --check 2906a10..c9743c6
```

A separate spec review approved the final behavior. A separate security and
quality review approved the hardened implementation after three blocking
findings were fixed.

## Boundary

The package tuple already has QEMU login and service proof. The real-system
installer itself is not hardware-proven yet. Packages are unsigned and are not
from the canonical Regolith archive. SHA-256 verification detects artifact
changes but is not a package signature or provenance attestation.

Rollback automatically removes packages recorded as introduced by the install
transaction. Pre-existing packages that were upgraded require manual exact
version restoration; the baseline records those versions. The script never
runs `autoremove`.
