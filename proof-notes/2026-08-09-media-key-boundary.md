# Media-key test boundary - 2026-08-09

The QEMU HMP input path was tested with `sendkey audio-up`. QEMU rejected the
key name with `invalid parameter: audio`, so this did not inject a multimedia
key event into the guest.

This is an input-testbed limitation, not a COSMIC OSD failure. The basic volume
OSD result is recorded separately.
