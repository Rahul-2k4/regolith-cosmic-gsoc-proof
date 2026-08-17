# 2026-08-18 clean inputd final tuple QEMU runtime

This note records the first runtime execution of the clean inputd package in
the final five-package tuple. It used an offline-prepared disposable qcow2
overlay derived from the protected Pop!_OS COSMIC image; the protected base was
not modified.

The prepared overlay received a temporary password and the exact five package
artifacts. The normal tuple runner then created a child copy-on-write overlay,
installed the tuple, rebooted, and authenticated through the greetd socket.

## Exact tuple

| Package | SHA-256 |
|---|---|
| `regolith-session-cosmic` | `8e3559e8dfd1eb33cbe3187da4772055a4f0ee048d69bf188ca0196b43635643` |
| `regolith-inputd` from source `3b3309a` | `5f2a280600b1a8a6ad01f6d5275b0d772d272a2e316b4439532c9b96e036b33b` |
| `regolith-displayd` | `11f0b101c02319b94664b6afb6e82325d3caaba137ea53768471e0a443056815` |
| `cosmolith` | `ad5af5edee6d278c4b9990c02f13ea3b715e260686cc6b58f2f5c48f6e6bb04e` |
| `cosmic-settings` | `5459b91e7d5281ff0727cef8431a31a7e1dc4a70031da855984938068563d29f` |

## Result

```text
PACKAGE_PREFLIGHT=PASS
GUEST_SSH_UP attempt=2
Setting up cosmic-settings ...
Setting up cosmolith ...
Setting up regolith-displayd ...
Setting up regolith-inputd ...
Setting up regolith-session-cosmic ...
GUEST_SSH_UP attempt=1
CANCEL_REPLY success
REPLY auth_message
REPLY success
START_REPLY success
RUNTIME_COMMANDS_COMPLETED=1
RUNTIME_RC=0
```

The runner then removed the child overlay, prepared overlay, HMP socket, log,
and temporary credential. No secret is retained in this repository.

This proves package installation, reboot, and greetd session start for the
clean inputd tuple. It remains QEMU-only and does not prove physical touchpad,
hardware hotplug, mixed-DPI, or maintainer acceptance.
