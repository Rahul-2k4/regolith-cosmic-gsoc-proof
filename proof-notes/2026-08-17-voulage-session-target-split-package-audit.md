# Voulage session target-split package audit - 2026-08-17

## Exact packet

This is a verified read-only audit of the exact Ubuntu Resolute Voulage session
packet. The Voulage model HEAD is `22105aa6`. The source candidate is
`regolith-session` `1948857`.

All six artifacts have version `1.2.0-1ubuntu1-1regolith-resolute`:

| Artifact | SHA-256 |
|---|---|
| `regolith-session-common` | `12a6f5750174a12b0a6fb3e7146fd8809eac9397429189eea43b2db07b11eb7b` |
| `regolith-session-cosmic` | `4015a52400f2c59c2eee33198175b88b54d6c660830273428036a16b324fac40` |
| `regolith-session-flashback-ext` | `5ce91ef537f854b60d8dd94c7d351d55a8c6b9c9fb72bf47afef339e2e6c5595` |
| `regolith-session-flashback` | `ceb08eaa29e247d928578e65f5962c5c6f2c60a8dd1cfc5f282868c4232284a3` |
| `regolith-session-gnome-targets` | `315c97c084b5abf02e8bf7ed4aa6c296713332152a980469ecb78ff44bcb7414` |
| `regolith-session-sway` | `41ad52c1b1c0852171498b8dc90ed0ca3d13f831cb3b05ca7fbb6b36c4637641` |

## Ownership result

The package ownership split is exact:

- `regolith-session-common` owns neither GNOME nor COSMIC target files.
- `regolith-session-gnome-targets` owns `regolith-gnome.target` and
  `gnome-session.target.d/regolith-gnome.conf`.
- `regolith-session-cosmic` owns `regolith-cosmic.target` and
  `regolith-cosmic.desktop`.

## Passing checks

The following checks passed for this packet:

- `regolith-session-package-audit.sh`
- `regolith-systemd-targets.sh`
- `regolith-cosmic-launch.sh`
- `regolith-cosmic-runtime-environment.sh`

## Limits

This audit does not prove an exact Ubuntu Resolute graphical guest, a full
archive pool/replay, or official publication, signing, or maintainer
acceptance. The result is package metadata, hash, ownership, and listed test
evidence for the exact read-only packet; Criterion 9 remains `Partial`.
