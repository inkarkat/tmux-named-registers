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
