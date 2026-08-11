# QEMU inputd feature-matrix runtime proof - 2026-08-12

## Scope

Fresh runtime verification in a copy-on-write Pop!_OS COSMIC qualification
guest. The base qualification disk was not modified. The existing public
verifier was used without installing packages or restarting user services.

Verifier: [`scripts/verify-inputd-candidate-qemu-runtime.sh`](../scripts/verify-inputd-candidate-qemu-runtime.sh)

## Installed tuple

- `regolith-inputd`: `0.4.1-1-1regolith-resolute`
- binary: `/usr/bin/regolith-inputd`
- installed binary SHA-256:
  `a81fb59d0ea754e942d1e561039799afd2107fa087ff0bc7bbe7bc8ab981ce21`

## Result

```text
Runtime verification failures: 0
PASS: installed package/binary, COSMIC environments, target/helper health, failed-unit check verified
```

The verifier checked the COSMIC desktop environment, active COSMIC target,
inactive GNOME target, active and successful inputd/displayd units with zero
restarts, and project-owned failed-unit state.

## Boundary

This is QEMU runtime evidence for the installed package tuple. It does not
prove physical hardware input, active-layout persistence, multimedia-key
delivery, native `cosmic-comp`, or a package built from inputd commit `271bc2a`.
The source feature-matrix proof and this runtime proof remain separate.
