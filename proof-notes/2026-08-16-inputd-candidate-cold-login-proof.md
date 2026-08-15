# Reviewed inputd candidate cold-login proof

Date: 2026-08-16

The reviewed `regolith-inputd` source pin `c658754` was built through Voulage
for Ubuntu Resolute as:

- `regolith-inputd 0.4.1-2-1regolith-resolute amd64`
- Package SHA-256:
  `90befdf9cac023cc8faa12ec1f1d82250908c9599c2949378f5878193215bb15`
- Installed executable SHA-256:
  `6594be730abfd7bf615453210df86e5edb6de798ac3fe38f164b0f70bebe3a3c`

The package was installed in a disposable QEMU overlay. After a cold reset
and graphical COSMIC login, `regolith-cosmic.target`,
`regolith-init-inputd.service`, and `regolith-init-displayd.service` were
active. The `regolith-inputd` and wrapper-owned `cosmolith` processes were
running, Sway IPC exposed the keyboard and pointer devices, and the generated
display profile still contained `1024x768@60.004Hz`. `dpkg --audit` was empty.

This closes package-to-cold-login integration for the reviewed inputd
candidate in QEMU. The guest has no physical touchpad, so touchpad
reverse-sync remains unproven. The direct `cosmic-settings` GUI path, native
`cosmic-comp`, hardware, and upstream acceptance remain open. The strict
proposal status remains `62-68%` and `4/12` criteria fully met.
