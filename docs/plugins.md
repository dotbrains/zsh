# Plugins

Plugins are managed by [zinit](https://github.com/zdharma-continuum/zinit) and configured in `conf.d/40-plugins.zsh`.

## Default Plugins

- `zsh-users/zsh-syntax-highlighting` - Syntax highlighting for commands
- `zsh-users/zsh-completions` - Additional completion definitions
- `zsh-users/zsh-autosuggestions` - Fish-like autosuggestions
- `Aloxaf/fzf-tab` - FZF integration for tab completion

## Oh-My-Zsh Snippets

The following Oh-My-Zsh plugin snippets are loaded:
- `OMZP::sudo` - ESC ESC to add sudo to command
- `OMZP::aws` - AWS CLI completions
- `OMZP::kubectl` - Kubernetes completions
- `OMZP::kubectx` - kubectx/kubens completions
- `OMZP::command-not-found` - Suggests package installation for missing commands

## Adding Plugins

Edit `~/.config/zsh/conf.d/40-plugins.zsh`:

```bash
# Add a new plugin
zinit light user/repository

# Load an Oh-My-Zsh plugin
zinit snippet OMZP::plugin-name
```

## Plugin Manager

Zinit is automatically installed on first run to `~/.local/share/zinit/`.

### Updating Plugins

```bash
zinit update --all
```

### Removing Plugins

Edit `conf.d/40-plugins.zsh` and remove the plugin line, then:
```bash
zinit delete user/repository
```

## Troubleshooting

### Zinit not installing
```bash
rm -rf ~/.local/share/zinit
exec zsh
```

### Plugin not loading
Check the plugin syntax and ensure the repository exists. View zinit logs:
```bash
zinit report user/repository
```
