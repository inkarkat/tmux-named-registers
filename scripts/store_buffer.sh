#!/bin/bash

readonly registerDirspec="${1:?}"; shift
readonly registerInboxFilespec="${registerDirspec}/in"

if [ ! -e "$registerInboxFilespec" ]; then
    if [ ! -d "$registerDirspec" ]; then
	tmux display-message "ERROR: Register storage directory does not exist: $registerDirspec"
    else
	tmux display-message "ERROR: Register inbox does not exist: $registerInboxFilespec"
    fi
    exit 1
fi
readonly register="${1:?}"; shift
readonly registerTargetFilespec="${registerDirspec}/${register,,}"
readonly registerName="register-${register,,}"

if [[ "$register" =~ [a-z] ]]; then
    mv -- "$registerInboxFilespec" "$registerTargetFilespec" || exit $?
    if ! tmux set-buffer -a -n "$registerName"; then	# set-buffer will fail if that name already exists.
	tmux delete-buffer -b "$registerName" && \
	    tmux set-buffer -a -n "$registerName"
    fi
    tmux display-message "Yanked into ${registerName}"
elif [[ "$register" =~ [A-Z] ]]; then
    tmux delete-buffer	# Remove the most recent buffer containing the appendage.
    cat "$registerInboxFilespec" >> "$registerTargetFilespec" && \
	tmux load-buffer -b "$registerName" "$registerTargetFilespec"	# load-buffer overrides any existing name without complaints.
    tmux display-message "Appended to ${registerName}"
fi
exit 0
