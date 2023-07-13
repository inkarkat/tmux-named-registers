# The last grep is required to remove non-digits from version such as "3.0a".
tmux_version="$(tmux -V | cut -d ' ' -f 2 | grep -Eo '[0-9\.]+')"
tmux-is-at-least() {
	if [[ $tmux_version == "$1" ]]; then
		return 0
	fi

	IFS='.' read -r -a tver <<< "$tmux_version"
	IFS='.' read -r -a wver <<< "$1"

	# fill empty fields in tver with zeros
	for ((i=${#tver[@]}; i<${#wver[@]}; i++)); do
		tver[i]=0
	done

	# fill empty fields in wver with zeros
	for ((i=${#wver[@]}; i<${#tver[@]}; i++)); do
		wver[i]=0
	done

	for ((i=0; i<${#tver[@]}; i++)); do
		if ((10#${tver[i]} < 10#${wver[i]})); then
			return 1
		elif ((10#${tver[i]} > 10#${wver[i]})); then
			return 0
		fi
	done
	return 0
}

if tmux-is-at-least 2.4; then
	bind_key_copy_mode() {
		local key="${1:?}"; shift
		tmux bind-key -T copy-mode-vi "$key" send-keys -X "$@"
		tmux bind-key -T copy-mode    "$key" send-keys -X "$@"
	}
else
	bind_key_copy_mode() {
		local key="${1:?}"; shift
		local tmux_command="${1:?}"; shift
		tmux_command="${tmux_command%-and-cancel}"
		tmux bind-key -t vi-copy    "$key" "$tmux_command" "$@"
		tmux bind-key -t emacs-copy "$key" "$tmux_command" "$@"
	}
fi
