# Voulage Resolute source-pin repair

The isolated Ubuntu Resolute/amd64 Voulage resolver initially stopped on two
unavailable source pins. The target overlay selected an unreachable
`cosmic-settings` commit and an old `regolith-displayd` commit.

The tested correction keeps the COSMIC work on the source-of-truth fork and
uses the refs already reachable from the builder:

| Package | Source | Ref |
| --- | --- | --- |
| `cosmic-settings` | `Rahul-2k4/cosmic-settings.git` | `bf6eefd1278aefb1cea92ead2d316503b31fcb78` |
| `regolith-displayd` | `Rahul-2k4/regolith-displayd.git` | `817becd9dc7e6a12f13f3f30f663555212ae78fa` |

In a fresh worktree, the two target-model edits passed `git apply --check
--unidiff-zero` and `git diff --check`. The exact Resolute resolver then
returned `0`, generated an 80-line next manifest, and recorded both refs. The
resolver log contained no `Error:`, `failed`, `not found`, `missing`,
`unavailable`, or `invalid` markers.

This closes source resolution for this isolated model check. It does not prove
that every package builds, that the archive is complete or signed, or that a
clean graphical Resolute guest can log in. The existing source-pin regression
test still expects an older `regolith-session` ref, so that test-drift finding
is retained separately rather than hidden.

The two source-pin edits remain local to the disposable worktree. No upstream
Voulage branch or canonical archive was changed.

