# Ubuntu 26.04 local-pool package closure

Date: 2026-08-17

This proof uses a fresh disposable `ubuntu:26.04` container. A local pool of
47 Resolute `.deb` files was indexed from the repository root with
`dpkg-scanpackages`; the resulting index contained 44 package entries.

The transaction was:

```text
apt-get update
apt-get install -y --no-install-recommends \
  regolith-session-cosmic \
  regolith-session-gnome-targets \
  regolith-session-sway
```

Results:

```text
APT_UPDATE_RC=0
INSTALL_RC=0
dpkg --audit -> DPKG_AUDIT_RC=0
```

The container used `APT::Sandbox::User=root` because APT's `_apt` sandbox
could not stage a read-only `file:` repository index. This affects only the
disposable harness. No dependency-forcing flags, direct `.deb` bypass, or
package downgrade was used.

## Selected artifact identities

| Package | Version | SHA-256 |
| --- | --- | --- |
| `regolith-session-cosmic` | `1.2.0-1ubuntu1-1regolith-resolute` | `4015a52400f2c59c2eee33198175b88b54d6c660830273428036a16b324fac40` |
| `regolith-session-gnome-targets` | `1.2.0-1ubuntu1-1regolith-resolute` | `315c97c084b5abf02e8bf7ed4aa6c296713332152a980469ecb78ff44bcb7414` |
| `regolith-session-sway` | `1.2.0-1ubuntu1-1regolith-resolute` | `41ad52c1b1c0852171498b8dc90ed0ca3d13f831cb3b05ca7fbb6b36c4637641` |
| `cosmic-session` | `1.0.0-1-1regolith-resolute` | `cd9693b28fc1e59f66f4a116634a79489ed008af9fc7ca070fbfdd3df0131509` |
| `regolith-displayd` | `0.3.4-1-1regolith-resolute` | `ae5249b164cae2c65499b7b38b31bdea050bfe28f7ab753e0233e9a4dde1d3ad` |
| `regolith-inputd` | `0.4.1-2-1regolith-resolute` | `52dfaba9617f046100ae0b32392662254e5411cc8d3c7c1265c57358e1901d34` |
| `cosmolith` | `0.1.0-1-1regolith-resolute` | `2e903bd96c7c6fe8539068b6f2df74e11d6436720f838b942a59b00672de4000` |
| `xrescat` | `1.2.1-4-1regolith-resolute` | `dbd43db036beecd08b89f897995c237601c8fa032d14be459d1a0c1347a960bd` |
| `fonts-nerd-font-bitstreamverasansmono` | `2.1.0-4-1regolith-resolute` | `1a1f94997d2bcc53e596f800cc38ab5397461683f8d3033c89d16e8a9e3200af` |

## Boundary

This closes the package dependency transaction in Ubuntu 26.04. It does not
prove a greeter-selected graphical COSMIC login, signed archive publication,
or hardware behavior. GNOME packages pulled by the explicit Sway target are
not treated as absent; the GNOME/COSMIC package-survivor criterion remains
partial until the exact archive and graphical boundaries are replayed.

The container also printed a NetworkManager post-install warning because no
system bus was running and some sysctls were read-only. The package
transaction still completed successfully and `dpkg --audit` was empty.
