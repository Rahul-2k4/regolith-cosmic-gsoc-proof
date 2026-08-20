# Displayd profile-storage package runtime - 2026-08-18

The displayd source branch `rahul/cosmic-display-profile-persistence-20260818`
was packaged through the isolated Voulage model branch
`rahul/displayd-model-91bdd26-20260818` at model commit `cf4daef2`.

Source commit: `44660e8df1f1e670e379a720ad403b9a6a2dc934`

Displayd package SHA-256:
`11ac1a713aa5437a1b598e590c5980127b84f150b671de0896acd36a078d78fd`

The package was installed together with the existing final COSMIC session,
COSMIC-feature inputd, cosmolith, and cosmic-settings artifacts in a disposable
Pop!_OS QEMU overlay. The run produced:

```text
PACKAGE_PREFLIGHT=PASS
GUEST_SSH_UP attempt=2
CANCEL_REPLY success
REPLY auth_message
REPLY success
START_REPLY success
RUNTIME_COMMANDS_COMPLETED=1
```

The runner removed its temporary overlay and HMP socket after the run. This
proves package installation and COSMIC session startup with the displayd
storage slice. It does not claim live Wayland `create_configuration` reapply.
