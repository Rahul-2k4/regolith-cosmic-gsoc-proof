# Voulage displayd repin and package proof - 2026-08-16

This records the exact personal-fork Voulage model and the resulting Ubuntu
Resolute package. It is package proof, not an upstream publication or a new
runtime claim.

## Inputs

- Voulage branch: [`chore/repin-displayd-87c2b677`](https://github.com/Rahul-2k4/voulage/tree/chore/repin-displayd-87c2b677)
- Voulage commit: [`92da34a7`](https://github.com/Rahul-2k4/voulage/commit/92da34a7d41b8120e1b7f385af521f683c3361ed)
- `regolith-displayd` source: [`87c2b67`](https://github.com/Rahul-2k4/regolith-displayd/commit/87c2b677cdd8b580998c4210e1bb73a572c5785d)
- Model assertion: `bash tests/regolith-session-source-pin.sh stage/unstable/package-model.json`

The assertion passed, and the resolver kept the other package pins unchanged.

## Artifact

- Target: Ubuntu Resolute, `unstable`, `amd64`
- Package: `regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb`
- Build result: `BUILD_RC=0`
- SHA-256: `941d1b04489bc3ccd178d942321ad529a3ae2e78b6da5eda1046c36a6f2f6b40`

`dpkg-deb` inspection confirmed the displayd binaries and both user units.
The packaged Kanshi unit is installed only under `regolith-gnome.target`;
the displayd unit is installed under both GNOME and COSMIC targets.

Lintian reported only the existing missing-manual-page warnings for the two
displayd binaries. No zero-warning claim is made.

This exact package was not installed in QEMU during this step. Signing,
canonical archive publication, upstream merge, and mentor acceptance remain
open. The strict proposal estimate remains `62-68%` and `4/12` fully met.
