# Configuration Guide

## Modular Configuration Files

Configuration files in `conf.d/` are loaded in numerical order:

- `00-variables.zsh` - Environment variables and PATH
- `10-history.zsh` - History configuration
- `20-keybindings.zsh` - Key bindings
- `30-completions.zsh` - Completion settings
- `40-plugins.zsh` - Plugin manager and plugins
- `50-theme.zsh` - Theme and prompt
- `99-local.zsh` - Local overrides

## Local Configuration

Machine-specific settings can be added to `~/.config/zsh/local.zsh`. This file is loaded last via the `99-local.zsh` configuration file.

## Adding Custom Aliases

Create a new file in `~/.config/zsh/aliases/`:
```bash
# ~/.config/zsh/aliases/custom.zsh
alias myalias="my command"
```

## Adding Custom Functions

Create a new file in `~/.config/zsh/functions/`:
```bash
# ~/.config/zsh/functions/custom.zsh
my_function() {
    echo "Hello from my function"
}
```

## XDG Base Directory Compliance

This configuration follows the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html):

| Purpose | Default Location | Environment Variable |
|---------|-----------------|---------------------|
| Configuration | `~/.config/zsh` | `$XDG_CONFIG_HOME/zsh` |
| Data | `~/.local/share/zsh` | `$XDG_DATA_HOME/zsh` |
| State (history) | `~/.local/state/zsh/history` | `$XDG_STATE_HOME/zsh/history` |
| Cache | `~/.cache/zsh` | `$XDG_CACHE_HOME/zsh` |

All XDG directories are automatically created on first run if they don't exist.
