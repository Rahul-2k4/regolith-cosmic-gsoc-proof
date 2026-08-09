# Inputd candidate verifier QEMU runtime proof - 2026-08-10

## Scope

This is a bounded runtime check of the already-installed inputd candidate in
the qualification QEMU guest. It does not claim physical hardware behavior,
native `cosmic-comp` display mutation, or release publication.

## Exact identity

- Package: `regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb`
- Package SHA-256:
  `759f87dc908182359a17d3930bf67b0f4c3a188fe02e75bdc71f7bd9238ff193`
- Installed version: `0.4.1-2-1regolith-resolute`
- Installed binary SHA-256:
  `b484e3f05f8042f217d1fca46507a8c1011c565bc2c69034b202f8d8599981eb`

The verifier binds its identity check to the installed package version and
binary hash. The package archive hash and binary hash are intentionally
recorded separately.

## Procedure

1. Copied the hash-verified package into the guest and installed it over the
   baseline `0.4.1-1-1regolith-resolute` package.
2. Logged in through the visible COSMIC greeter.
3. Ran `scripts/verify-inputd-candidate-qemu-runtime.sh` with the expected
   version and installed-binary hash.
4. Did not provide `INPUTD_HELPER`, so no live input setting was changed.

## Result

`PASS`: runtime failures `0`.

The proof recorded:

- `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway` for Sway and inputd;
- `regolith-cosmic.target=active`;
- `regolith-gnome.target=inactive`;
- both `regolith-init-inputd.service` and `regolith-init-displayd.service`
  active with `Result=success` and `NRestarts=0`;
- both helpers present in the COSMIC target dependency graph;
- no `gnome-session-bin` process;
- no project-owned failed user unit;
- zero verifier failures.

An unrelated Polkit autostart unit appeared in the general user-failed-unit
listing. The verifier intentionally excludes unrelated units; this proof does
not claim a globally empty failed-unit list.

## Evidence

- [Verifier script](../scripts/verify-inputd-candidate-qemu-runtime.sh)
- [Package version](../artifacts/inputd-candidate-verifier-qemu-20260810/01-package-version.txt)
- [Installed binary hash](../artifacts/inputd-candidate-verifier-qemu-20260810/03-binary-sha256.txt)
- [COSMIC target](../artifacts/inputd-candidate-verifier-qemu-20260810/05-regolith-cosmic.target.txt)
- [GNOME target](../artifacts/inputd-candidate-verifier-qemu-20260810/05-regolith-gnome.target.txt)
- [Inputd service state](../artifacts/inputd-candidate-verifier-qemu-20260810/06-regolith-init-inputd.service.txt)
- [Displayd service state](../artifacts/inputd-candidate-verifier-qemu-20260810/06-regolith-init-displayd.service.txt)
- [Verifier result](../artifacts/inputd-candidate-verifier-qemu-20260810/11-result.txt)

The guest remains on the candidate during this capture. It must be restored to
the baseline package before the QEMU testbed is handed back.
