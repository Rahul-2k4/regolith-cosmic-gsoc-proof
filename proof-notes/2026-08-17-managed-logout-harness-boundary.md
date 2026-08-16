# Managed logout harness boundary

Date: 2026-08-17

This note records a bounded QEMU validation attempt. It is not a product
success claim.

## Verified before the boundary

- A copy-on-write overlay was used, so the base guest image was not modified.
- The exact session, inputd, displayd, and wm-config package tuple installed.
- The guest rebooted and greetd returned `START_REPLY success` for COSMIC.
- `regolith-cosmic.target`, inputd, and displayd were active after login.

## Boundary

The harness could not select a stable local graphical logind session for the
managed termination request. Opening the SSH command creates a transient
remote logind session while the guest session list is being inspected. The
harness therefore exited before issuing a valid termination request.

Managed logout, process teardown after logind termination, full shutdown, and
native idle/logind semantics remain unproven. The base image and product
packages were not changed. The strict project ledger remains 5/12 criteria
fully met, QEMU-only, at 62-68%.
