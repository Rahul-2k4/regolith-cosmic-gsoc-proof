# Final COSMIC tuple settings-daemon integration - 2026-08-18

## Scope

The final COSMIC tuple runner now requires seven explicit package files. It
verifies and stages `regolith-session-common` alongside the six COSMIC
runtime packages, then installs the complete staged set with
`apt-get install`.

## Canonical tuple

The canonical package identities are copied from
`artifacts/mentor-test-2026-08-18.sha256`:

| Artifact | SHA-256 |
|---|---|
| `regolith-session-cosmic_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb` | `8e3559e8dfd1eb33cbe3187da4772055a4f0ee048d69bf188ca0196b43635643` |
| `regolith-session-common_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb` | `bcf78bbabd644bc2e4c382c7eefb0a525e9f1b7dc4852b0473213901989dcf7f` |
| `regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb` | `a277811b7843791b3556f2bbb0d5c5a600b483f41f34d71f5f75cad08886aa19` |
| `regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb` | `949b9aedf8b4e64f2feeabc67947e7a64d6ca0cfb810e11a87896fb654afea1d` |
| `cosmolith_0.1.0-1-1regolith-resolute_amd64.deb` | `ad5af5edee6d278c4b9990c02f13ea3b715e260686cc6b58f2f5c48f6e6bb04e` |
| `cosmic-settings_1.0.12-1-1regolith-resolute_amd64.deb` | `5459b91e7d5281ff0727cef8431a31a7e1dc4a70031da855984938068563d29f` |
| `cosmic-settings-daemon_0.1.0-1-1regolith-resolute_amd64.deb` | `16dbe4a274d31080055a6f0a2699f9b9d0d1a542c44798c9724ff3a0bfbb2fe1` |

The runner stages these files as `regolith-session-cosmic.deb`,
`regolith-session-common.deb`, `regolith-inputd.deb`,
`regolith-displayd.deb`, `cosmolith.deb`, `cosmic-settings.deb`, and
`cosmic-settings-daemon.deb`. `COMMON_DEB` is required for the
`regolith-session-common` input; `COMMON_SHA` is fixed to the canonical
manifest hash above.

The source pins currently recorded by the runner are:

| Component | Source ref |
|---|---|
| `regolith-session-cosmic` | `54d5684` |
| `regolith-inputd` | `rahul/voulage-vendor-optin-20260818` |
| `regolith-displayd` | `rahul/cosmic-live-apply-20260818` |
| `cosmolith` | `592c1f6` |
| `cosmic-settings` | `e530ab7` |

## Verification contract

The runbook contract and test require the exact seven manifest lines, all
seven expected hashes, all seven staged names, and the current source refs.
They also preserve the cleanup and password-stdin checks.

Expected local checks:

```text
bash -n scripts/run-final-cosmic-tuple.sh
bash scripts/run-final-cosmic-tuple.sh --contract-test
CONTRACT_TUPLE=PASS
bash tests/test-final-cosmic-tuple-runbook.sh
RUNBOOK_CONTRACT=PASS
git diff --check
```

These checks prove the source and runbook contract only. They do not prove a
graphical runtime session.

## QEMU downgrade correction

The first controller attempt after `c966e77` failed before package mutation.
The exact `regolith-session-common` package was a downgrade relative to the
disposable guest state, and the runner used `apt-get install -y` without
`--allow-downgrades`. APT stopped at that transaction policy check.

The disposable QEMU command now uses:

```text
DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-downgrades /tmp/regolith-final-cosmic-tuple-pkgs/*.deb
```

This permission is scoped to the disposable overlay runner. It allows the
fresh test guest to converge on the exact seven-package tuple without
changing the real-system installer or broadening its mutation policy. The
failed attempt changed no package state and does not count as runtime proof;
the corrected seven-package tuple still requires a successful controller run.

## Historical QEMU result

The earlier QEMU run is historical and was not a seven-explicit-package
execution. At the runner boundary it supplied six explicit project files:
`regolith-session-cosmic`, `regolith-inputd`, `regolith-displayd`,
`cosmolith`, `cosmic-settings`, and `cosmic-settings-daemon`.
`regolith-session-common` was resolved as a package dependency rather than
being supplied as an explicit runner input.

That run reported successful package-manager completion, reboot, greetd
authentication, and COSMIC session launch. It supports only that historical
six-file result. The current seven-package tuple has not been run through a
controller yet, so no seven-explicit-package runtime claim is made here.
