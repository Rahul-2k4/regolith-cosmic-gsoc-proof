# Voulage session rebuild and cold-reset proof

Date: 2026-08-11

This note records a package and runtime check for the reviewed
`regolith-session` source at [`7fb72a8d`](https://github.com/Rahul-2k4/regolith-session/commit/7fb72a8d93e8b33fc6bfbca9292398252003b477).

## Build

The source was built through the reviewed Voulage local-build path with the
Resolute package suffix. The build returned exit code 0. The session package
tests for the COSMIC runtime teardown and systemd target metadata passed.

The resulting packages were:

| Package | Version | SHA-256 |
|---|---|---|
| `regolith-session-common` | `1.2.0-1ubuntu1-1-1regolith-resolute` | `082263212a909bd233967c1e1ff5d04f303eee7829beae85b2dc48bdf55d0642` |
| `regolith-session-cosmic` | `1.2.0-1ubuntu1-1-1regolith-resolute` | `515ae31f1d33caf54de79cafe60006a45cd8d728a404c7ffd5585b5c6eeca751` |
| `regolith-session-sway` | `1.2.0-1ubuntu1-1-1regolith-resolute` | `b032ed8489b8fe163635c217c49d9ec8a1620c5ff2556dcba2a702b8b5112706` |

Lintian still reports package-quality findings, including the local maintainer
identity, a legacy Flashback dependency, and missing manual pages for some
binaries. This is build evidence, not a claim of release readiness.

## QEMU check

The packages were tested in the disposable, snapshot-backed qualification VM.
An initial staged compatibility pass exposed a file-ownership collision with
the preinstalled session package. Force recovery was used only inside that
snapshot, and it is not counted as clean package-install proof. The rebuilt
Voulage session packages then installed cleanly as an upgrade over the staged
state.

After a cold reset and a retry at the login boundary, the guest reached the
COSMIC-backed Sway session with:

- the three Voulage session packages at the versions above;
- `regolith-cosmic.target` active;
- `regolith-init-inputd.service` and `regolith-init-displayd.service` active
  under that target;
- no failed systemd units; and
- an empty `dpkg --audit` result.

The guest was powered down through the QEMU monitor after the check. The
captured screen is [available here](assets/2026-08-11-reviewed-voulage-cold-login.png).

## Boundary

This proves the rebuilt session package path and a cold-reset login in QEMU.
It does not prove a native `cosmic-comp` session, because this test uses Sway;
`cosmic-randr` returned `NoCompositor` in that environment. It also does not
prove hardware display, hotplug, mixed-DPI, physical touchpad, signing,
canonical publication, or mentor acceptance.
