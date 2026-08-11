# Native Trixie COSMIC binary-build proof

Date: 2026-08-12

The personal Voulage branch
[`rahul/native-trixie-cosmic-20260812`](https://github.com/Rahul-2k4/voulage/tree/rahul/native-trixie-cosmic-20260812)
contains the Trixie model, quilt/vendor metadata, generated Cargo-config
ignore, and the temporary non-publishing build helper. The final helper
commit is [`09b69eab`](https://github.com/Rahul-2k4/voulage/commit/09b69eabd3395ca11fe72253257b247881f75c52).

## CI result

GitHub Actions run
[`31533503633`](https://github.com/Rahul-2k4/voulage/actions/runs/31533503633)
completed successfully for both matrix entries:

- `cosmic-session` used the source-declared Rust `1.93.0` toolchain and built
  `cosmic-session_1.0.0-1regolith-trixie_amd64.deb`.
- `cosmic-settings-daemon` used the source-declared Rust `1.90.0` toolchain
  and built
  `cosmic-settings-daemon_0.1.0-1regolith-trixie_amd64.deb`.
- Both source and binary `dpkg-buildpackage` stages completed.
- Lintian completed for both packages; its warnings remain recorded in the
  CI logs and are not being presented as a zero-warning result.

The uploaded unsigned evidence artifacts are:

- `native-trixie-cosmic-session-unsigned-build-evidence`, artifact `9117930589`,
  digest `sha256:c8f6f6058447e8e87da4608b28de799f1e3f18bf4e3d49f2aabafc299a66f3d4`.
- `native-trixie-cosmic-settings-daemon-unsigned-build-evidence`, artifact
  `9118109255`, digest
  `sha256:0780245a3315650258466dff834ed758725a0b08aca8b415fd76b9760d448a48`.

## Boundary

This is native Trixie binary-build evidence through Voulage. The workflow is
explicitly unsigned and uses a temporary archive-setup override; it does not
sign packages, publish an apt repository, or establish maintainer/mentor
acceptance. The CI log's local `pkgpublish` wording refers to the workflow's
evidence directory, not a public repository publication.

This advances the packaging criterion from model/source integrity to a
validated unsigned build, but criterion 10 remains **Partial** until the
release path, signing, publication, and review boundary are agreed.
