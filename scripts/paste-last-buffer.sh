#!/bin/bash

lastNonRegisterBuffer="$(tmux list-buffers -F '#{buffer_name}' | grep --invert-match -e '^register-.$' | head -n 1)" || exit
[ -n "$lastNonRegisterBuffer" ] || exit

# Need to load the buffer to make it the current one (for future pastes via
# prefix + ]).
TMPFILE="$(mktemp --tmpdir "$(basename -- "$0")-XXXXXX" 2>/dev/null || echo "${TMPDIR:-/tmp}/$(basename -- "$0").$$$RANDOM")"
tmux save-buffer -b "$lastNonRegisterBuffer" "$TMPFILE" \
    && tmux load-buffer -b "$lastNonRegisterBuffer" "$TMPFILE"
rm --force -- "$TMPFILE"

exec tmux paste-buffer -b "$lastNonRegisterBuffer"
