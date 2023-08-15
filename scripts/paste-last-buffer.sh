#!/bin/bash

count="${1:?}"; shift

readarray -t nonRegisterBuffers < <(tmux list-buffers -F '#{buffer_name}' | grep --invert-match -e '^register-.$')
bufferName="${nonRegisterBuffers[$count]}"
[ -n "$bufferName" ] || exit

if [ $count -eq 0 ]; then
    # Need to load the buffer to make it the current one (for future pastes via
    # prefix + ]).
    TMPFILE="$(mktemp --tmpdir "$(basename -- "$0")-XXXXXX" 2>/dev/null || echo "${TMPDIR:-/tmp}/$(basename -- "$0").$$$RANDOM")"
    tmux save-buffer -b "$bufferName" "$TMPFILE" \
	&& tmux load-buffer -b "$bufferName" "$TMPFILE"
    rm --force -- "$TMPFILE"
fi

exec tmux paste-buffer -b "$bufferName"
