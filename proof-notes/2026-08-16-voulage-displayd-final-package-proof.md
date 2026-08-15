# Final Voulage displayd package proof - 2026-08-16

This is the final package artifact from the corrected displayd source and the
manpage packaging cleanup. It does not claim a fresh runtime installation.

## Source and model

- Displayd source: [`294b219`](https://github.com/Rahul-2k4/regolith-displayd/commit/294b21961829621f8c466f20e2fed802b3c0e97b)
- Voulage branch: [`chore/repin-displayd-manpages-manifest-294b219`](https://github.com/Rahul-2k4/voulage/tree/chore/repin-displayd-manpages-manifest-294b219)
- Voulage commit: [`5b4ee085`](https://github.com/Rahul-2k4/voulage/commit/5b4ee085)
- Target: Ubuntu Resolute, `unstable`, `amd64`
- Model assertion, JSON validation, and diff checks passed.

## Artifact

- Package: `regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb`
- Build result: `BUILD_RC=0`
- SHA-256: `ae5249b164cae2c65499b7b38b31bdea050bfe28f7ab753e0233e9a4dde1d3ad`

Package inspection found both displayd binaries, both manpages, the displayd
user unit wanted by GNOME and COSMIC, and the GNOME-only Kanshi user unit.
The two missing-manual-page warnings are closed. The full Voulage changes
artifact still reports one warning for the generated dbgsym package because
it contains no debug symbols; this is not reported as zero-warning packaging.

The exact package was not installed in QEMU during this step. It is unsigned
and exists on a personal Voulage branch. Canonical publication, upstream merge,
and mentor acceptance remain open. The strict status remains `62-68%` and
`4/12` fully met.
