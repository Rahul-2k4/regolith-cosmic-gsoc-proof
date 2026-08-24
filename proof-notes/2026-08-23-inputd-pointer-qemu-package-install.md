# Inputd pointer package QEMU installation checkpoint — 2026-08-23

This is a disposable QEMU package-install and cold-boot checkpoint. It is not
a full graphical COSMIC-login promotion.

## Package

The exact e8fce66 package was installed with `dpkg -i` in a copy-on-write guest
overlay. The in-guest hash matched the source artifact:

```text
650bd6f38bf67a08e140fa566aff4e7c63b2a41fc2cc60b04aada670a420823b
```

The guest already contained the COSMIC session, displayd, and local Resolute
package tuple. Installation completed successfully, followed by a cold
reboot. `dpkg --audit` remained clean and no system units were failed after
boot.

## Boundary

The headless disposable guest uses `agreety` on a virtual terminal and did not
perform a graphical greetd login automatically. Direct launcher attempts were
also stopped by the existing COSMIC session-bus/harness boundary. Therefore
this note proves package installation and cold boot only; it does not promote
a runtime criterion. A graphical cold-login harness remains the next gate.
