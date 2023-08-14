# Tmux named registers

_Tmux plugin for yanking into and pasting from 26 buffers named a-z (like in vi)._

This plugin offers yanking into 26 named buffers _a-z_; with uppercase letters, the selection is appended; just like in vi.

Register contents are persisted (also across restarts) in `~/.local/share/tmux/named-registers/`

### Key bindings

- {copy} <kbd>"</kbd> <kbd>a</kbd> ... <kbd>z</kbd> <br>
  Store the current selection in the named register a ... z.
- {copy} <kbd>"</kbd> <kbd>A</kbd> ... <kbd>Z</kbd> <br>
  Append the current selection to the existing contents in the named register a ... z.
- <kbd>prefix</kbd> <kbd>"</kbd> <kbd>a</kbd> ... <kbd>z</kbd> <br>
  Paste the contents of the named register a ... z into the current pane.
  The next built-in paste (prefix + ]) will repeat the paste of that register.
- <kbd>prefix</kbd> <kbd>"</kbd> <kbd>"</kbd>
  Paste the last copied (non-register) buffer (also on subsequent built-in pastes).

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

    set -g @plugin 'inkarkat/tmux-named-registers'

Hit `prefix + I` to fetch the plugin and source it. You should now be able to use the plugin.

### Manual Installation

Clone the repo:

    $ git clone https://github.com/inkarkat/tmux-named-registers ~/clone/path

Add this line to the bottom of `.tmux.conf`:

    run-shell ~/clone/path/named-registers.tmux

Reload tmux environment with: `$ tmux source-file ~/.tmux.conf`. You should now be able to use the plugin.

### License

[GPLv3](LICENSE)
