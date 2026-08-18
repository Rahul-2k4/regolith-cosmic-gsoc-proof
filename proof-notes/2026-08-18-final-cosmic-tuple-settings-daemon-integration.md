# Final COSMIC tuple settings-daemon integration - 2026-08-18

## Scope

The final COSMIC tuple runner now includes `cosmic-settings-daemon` in the
COSMIC runtime tuple. The runner verifies, stages, copies, and installs it
with the existing five artifacts. Existing package hashes are unchanged.

## Tuple contract

| Artifact | SHA-256 |
|---|---|
| `regolith-session-cosmic` | `8e3559e8dfd1eb33cbe3187da4772055a4f0ee048d69bf188ca0196b43635643` |
| `regolith-inputd` | `b11dd8a4495aae59687a4ae4650e242e8fc75f859fb81e8580f34a9ccbdfaf52` |
| `regolith-displayd` | `4fc2d5b9a921df69ccfb01a7e34b3b97d915db29e08a0998f9f12011b92eaefe` |
| `cosmolith` | `ad5af5edee6d278c4b9990c02f13ea3b715e260686cc6b58f2f5c48f6e6bb04e` |
| `cosmic-settings` | `5459b91e7d5281ff0727cef8431a31a7e1dc4a70031da855984938068563d29f` |
| `cosmic-settings-daemon` | `16dbe4a274d31080055a6f0a2699f9b9d0d1a542c44798c9724ff3a0bfbb2fe1` |

The daemon artifact is supplied at runtime through `SETTINGS_DAEMON_DEB`:

```text
/home/rahul/Desktop/GSoC_2026/ccextractor/regolith/voulage/.worktrees/codex-cosmic-settings-daemon-build-20260816/pkgpublish/ubuntu/resolute/unstable/cosmic-settings-daemon_0.1.0-1-1regolith-resolute_amd64.deb
```

For a QEMU execution, use
`/Users/rahul/Desktop/Gsoc/.tmp/greetd-session-cosmic-client.py` as
`LOGIN_CLIENT` and pass the existing five current-tuple paths together with
the daemon path above.

The runner installs the staged project packages with `apt-get install` rather
than raw `dpkg -i`, so declared Qt dependencies such as `qt5ct` and `qt6ct`
are resolved by the guest package manager. It waits for any initial guest
package-manager activity to finish before starting this install.

The inputd artifact in this tuple is the reverse-sync candidate from source
commit `ff5ae80c6c8ae2f8bcae44e63314c7fc18ef3687`. Its Voulage model commit is
`c8f714e7536bfbffd78d98bdc947b96df30e7a8e`; the vendored build repaired the
missing Cargo registry manifests and direct Lintian reported zero issues.

The displayd artifact in this tuple is built from source commit
`af5112eee8ae085eb9b73b1b9b49a18a37bcf7e` through Voulage model commit
`7c8491bad4c99cdae21a58d9f900970009fbb071`. Its vendored build and package
checks passed; only the two existing binary manual-page warnings remain.

## Verification

The following local checks passed:

```text
bash -n scripts/run-final-cosmic-tuple.sh
bash scripts/run-final-cosmic-tuple.sh --contract-test
CONTRACT_TUPLE=PASS
bash tests/test-final-cosmic-tuple-runbook.sh
git diff --check
```

The syntax, repository contract, and diff checks exited `0`. The contract
asserts the unchanged five package hashes and the new settings-daemon hash.

## Runtime result

The dependency-aware tuple was run on the Pop!_OS COSMIC QEMU guest after the
runner change:

```text
PACKAGE_PREFLIGHT=PASS
GUEST_SSH_UP attempt=1
6 upgraded, 24 newly installed, 0 to remove
GUEST_SSH_UP attempt=1
CANCEL_REPLY success
REPLY auth_message
REPLY success
START_REPLY success
RUNTIME_COMMANDS_COMPLETED=1
```

The guest installed all six project packages and the required Qt runtime
dependencies, rebooted, authenticated through greetd, and started the COSMIC
session launch path. The runner exited successfully and cleaned up the
temporary QEMU state.

## Final source tuple rerun

The tuple was rerun after replacing both the displayd and inputd artifacts:

```text
PACKAGE_PREFLIGHT=PASS
GUEST_SSH_UP attempt=1
6 upgraded, 24 newly installed, 0 to remove
GUEST_SSH_UP attempt=7
CANCEL_REPLY success
REPLY auth_message
REPLY success
START_REPLY success
RUNTIME_COMMANDS_COMPLETED=1
```

This run used displayd source `af5112e` and inputd source `ff5ae80c`, with
their corresponding Voulage packages listed above. It completed the same
dependency-aware install, reboot, greetd login, and COSMIC session start.
