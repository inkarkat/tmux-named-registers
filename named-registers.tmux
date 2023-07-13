#!/bin/bash

fail() {
    tmux display-message "ERROR: tmux-named-registers ${1:-encountered an unspecified problem.}"
    exit 3
}

readonly scriptDir="$([ "${BASH_SOURCE[0]}" ] && dirname -- "${BASH_SOURCE[0]}" || exit 3)"
[ -d "$scriptDir" ] || fail 'cannot determine script directory!'
absoluteScriptDir="$(cd "$scriptDir" && printf %s "$PWD" || exit 3)" || fail
printf -v quotedScriptDir '%q' "$absoluteScriptDir"

# shellcheck source=./scripts/helpers.sh
source "${absoluteScriptDir}/scripts/helpers.sh"

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
	    tmux bind-key -T yank-register-query "$register" run-shell "${quotedScriptDir}/scripts/store_buffer.sh $quotedRegistersDirspec $register"
	done
    done
}

main() {
    set_bindings
}

main
