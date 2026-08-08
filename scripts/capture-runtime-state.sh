#!/usr/bin/env bash

# Capture guest runtime state without changing the installed system.

if [ "$#" -ne 1 ]; then
  printf 'Usage: %s OUTPUT_DIRECTORY\n' "$0" >&2
  exit 2
fi

OUTPUT_DIR=$1
mkdir -p "$OUTPUT_DIR" || exit 1

capture() {
  local output=$1
  shift
  {
    printf '$'
    printf ' %q' "$@"
    printf '\n'
    "$@"
    status=$?
    printf '\ncommand_exit_status=%s\n' "$status"
  } >"$OUTPUT_DIR/$output" 2>&1 || true
}

packages=(
  regolith-session-cosmic
  regolith-wm-config
  regolith-sway-root-config
  regolith-sway-ilia
  regolith-sway-default-style
  regolith-sway-cosmic-idle
  regolith-inputd
  regolith-displayd
)

capture 01-dpkg-query.txt dpkg-query -W -f='${binary:Package}\t${Version}\t${Status}\n' "${packages[@]}"
capture 02-dpkg-audit.txt dpkg --audit
capture 03-loginctl-sessions.txt loginctl list-sessions --no-legend

units=(
  regolith-cosmic.target
  regolith-init-inputd.service
  regolith-init-displayd.service
)
capture 04-user-units-active.txt systemctl --user is-active "${units[@]}"
capture 05-user-units-show.txt systemctl --user show "${units[@]}"
capture 06-desktop.txt env XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP-}"
capture 07-processes.txt sh -c 'ps -eo user=,pid=,ppid=,comm=,args= | grep -E "(cosmic|regolith|sway|inputd|displayd|gtklock|swayidle)" | grep -v grep'
capture 08-user-failed-units.txt systemctl --user --failed --no-legend
capture 09-system-failed-units.txt systemctl --failed --no-legend
