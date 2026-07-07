# regolith-session kanshi mask QEMU proof - 2026-07-04

Status: `QEMU proof passed`

## Claim

The experimental Regolith COSMIC session helper now masks the remaining legacy display helper, `regolith-init-kanshi.service`, along with `regolith-init-inputd.service` and `regolith-init-displayd.service`.

This closes the earlier clean-session blocker where `regolith-init-kanshi.service` could remain active or failed after a COSMIC login.

## Source change

- repo: `regolith-session`
- branch: `rahul/cosmic-session-week1-2`
- commit: `14cfaab` (`Mask kanshi helper in COSMIC session`)
- files:
  - `usr/lib/regolith/regolith-session-cosmic.sh`
  - `tests/regolith-cosmic-autostart.sh`

Source tests passed on the QEMU test host:

```bash
bash tests/regolith-cosmic-autostart.sh
bash tests/regolith-cosmic-status-bar.sh
```

## Runtime proof environment

- host: local QEMU test host alias, redacted in this public note
- guest: Pop/COSMIC QEMU disk `pop-cosmic-qual.qcow2`
- proof assets: raw reboot/session assets retained in the private working vault

The staged helper was copied into the guest and installed over `/usr/lib/regolith/regolith-session-cosmic.sh` after backing up the original helper into the proof directory.

Installed helper checksum after reboot:

```text
1b93402afe35508e4465268e58aad1fa003e233fbd4d89679862823879e2362b  /usr/lib/regolith/regolith-session-cosmic.sh
1b93402afe35508e4465268e58aad1fa003e233fbd4d89679862823879e2362b  <guest-home>/regolith-session-cosmic.sh.kanshi-14cfaab
```

Source: `16-helper-sha-after-reboot.txt`

## Result

After guest reboot, failed user units were clean:

```text
11-failed-units-after-reboot.txt: 0 bytes
```

`regolith-init-kanshi.service` after reboot:

```text
Loaded: masked (Reason: Unit regolith-init-kanshi.service is masked.)
Active: inactive (dead)
```

Source: `12-kanshi-status-after-reboot.txt`

All three legacy helpers after reboot:

```text
regolith-init-inputd.service: masked, inactive
regolith-init-displayd.service: masked, inactive
regolith-init-kanshi.service: masked, inactive
```

Source: `20-legacy-helper-statuses.txt`

## Before/after note

Before installing the staged helper, `regolith-init-kanshi.service` was active and running `kanshi`:

```text
Active: active (running)
Exec: /usr/bin/kanshi -c <guest-home>/.config/regolith3/kanshi/config
kanshi: no profile matched
```

Source: `04-kanshi-status-before.txt`

After the patched helper and reboot, the service was masked and inactive with no failed user units.

## Caveats

- This is QEMU proof, not full laptop boot proof.
- The patched helper remained staged in the QEMU guest for the next validation step; the original helper backup is retained with the private raw proof assets.
- This proof validates the legacy-helper masking behavior. It does not yet validate `regolith-inputd` live watcher behavior or end-to-end Voulage package install.

## Follow-up note

The later `regolith-inputd` mouse live-watch proof used a temporary helper that writes through `cosmic_config::ConfigSet`. It did not use a manual config-file overwrite, and it did not require claiming a full `cosmic-settings` UI click path.
