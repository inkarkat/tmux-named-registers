#!/bin/bash

readonly projectDir="$([ "${BASH_SOURCE[0]}" ] && cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
[ -d "$projectDir" ] || fail 'cannot determine script directory!'
printf -v quotedScriptDir '%q' "${projectDir}/scripts"

# shellcheck source=./scripts/helpers.sh
source "${projectDir}/scripts/helpers.sh"

readonly registersDirspec="${XDG_DATA_HOME:-${HOME}/.local/share}/tmux/named-registers"
[ -d "$registersDirspec" ] || mkdir --parents -- "$registersDirspec" || fail "cannot initialize data store at $registersDirspec"
printf -v quotedRegistersDirspec '%q' "$registersDirspec"

set_bindings() {
    # Integrate with tmux-copycat so that a copycat search / mode is properly
    # terminated. The plugin tries to extend the mapping on its own, but this
    # doesn't work and results in copycat mode never being exited, so n/N after
    # any copycat search will continue to jump to matches instead of being
    # inserted literally.
    local pluginPath="$(tmux show-env -g TMUX_PLUGIN_MANAGER_PATH 2>/dev/null | cut -f2 -d=)"
    local copycatScriptFilespec="${pluginPath:-${HOME}/.tmux/plugins/tmux-copycat/scripts/copycat_mode_quit.sh}"
    [ -x "$copycatScriptFilespec" ] || copycatScriptFilespec=''
    bind_key_copy_mode '"' copy-pipe "cat > ${quotedRegistersDirspec}/in; ${copycatScriptFilespec}${copycatScriptFilespec:+; }tmux switch-client -T yank-register-query"

    tmux bind-key '"' switch-client -T paste-register-query

    local register; for register in a b c d e f g h i j k l m n o p q r s t u v w x y z
    do
	tmux bind-key -T paste-register-query "$register" load-buffer -b "register-$register" "${registersDirspec}/${register}" \\\; paste-buffer -b "register-$register"

	for register in "$register" "${register^^}"
	do
	    tmux bind-key -T yank-register-query "$register" run-shell "${quotedScriptDir}/store_buffer.sh $quotedRegistersDirspec $register"
	done
    done

    tmux bind-key -T paste-register-query '"' run-shell "${projectDir}/scripts/paste-last-buffer.sh 0"

    for register in 1 2 3 4 5 6 7 8 9
    do
	tmux bind-key -T paste-register-query "$register" run-shell "${projectDir}/scripts/paste-last-buffer.sh $register"
    done
}

tmux-is-at-least 2.1 || exit 0
set_bindings
