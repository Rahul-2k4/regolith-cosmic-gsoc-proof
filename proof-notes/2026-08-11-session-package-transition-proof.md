# Session package ownership transition proof - 2026-08-11

## Scope

This note records a disposable QEMU package-transition check for the reviewed
`regolith-session` source fix. It does not claim a clean install from an empty
base, package signing, publication, or hardware support.

## Source and package

The personal-fork source commit is
[`b74dfe3`](https://github.com/Rahul-2k4/regolith-session/commit/b74dfe3d9a4b2dd848176d181f2d1f853115c5c8).
It adds `Replaces: regolith-session-sway` to the
`regolith-session-common` package stanza and adds a stanza-aware regression
assertion to the systemd-target test.

The Voulage local build returned exit code `0`. The resulting package was:

```text
regolith-session-common_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb
SHA-256: 8f90f360ca99c35338ade5bf722afc9054ac8787a38cad2bcda7649ab97371d5
Replaces: regolith-session-sway
```

The focused session target tests passed. Lintian still reported known errors
and warnings, so this is not a zero-Lintian or release-publication result.

## Transition result

Installing the original staged packet first returned a non-zero status because
`regolith-session-common` attempted to overwrite a path owned by
`regolith-session-sway`. The rebuilt `b74dfe3` common package was then installed
as the transition package. That install and configuration both returned `0`.

The follow-up checks showed:

- the GNOME drop-in was owned by `regolith-session-common`;
- `dpkg --audit` was empty;
- `systemctl --failed --no-legend` returned no failed units;
- the user `regolith-cosmic.target` was active.

## Boundary

The guest started from a snapshot that already contained the older package
tuple. This proves the ownership transition and recovery path, not a clean
from-empty-base installation. The disposable QEMU instance was powered down
through HMP and its monitor socket was absent afterward.
