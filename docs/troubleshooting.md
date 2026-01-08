# Troubleshooting

## Common Issues

### Zinit not installing

If zinit fails to install automatically:

```bash
rm -rf ~/.local/share/zinit
exec zsh
```

### Submodules not initialized

If the Nord dircolors theme isn't loading:

```bash
cd ~/.config/zsh
git submodule update --init --recursive
```

### History not saving

Check that the state directory exists and has correct permissions:

```bash
mkdir -p ~/.local/state/zsh
chmod 700 ~/.local/state/zsh
```

If history file exists but isn't being written to:
```bash
# Check HISTFILE variable
echo $HISTFILE

# Should output: /Users/youruser/.local/state/zsh/history
```

### Slow startup

Profile your startup time to identify bottlenecks:

```bash
# Time a single startup
time zsh -i -c exit

# Detailed profiling
zmodload zsh/zprof
# ... at the end of your zshrc:
zprof
```

Common causes:
- Too many plugins
- Slow commands in configuration files (e.g., `brew shellenv`)
- Large history file

### Commands not found

If your PATH is incorrect:

```bash
# Check current PATH
echo $PATH

# Reload configuration
source ~/.zshrc

# Check if commands are in expected locations
which brew
which git
```

### Theme not loading

If Nord colors aren't applied:

```bash
# Check if submodule is initialized
ls -la ~/.config/zsh/zsh-dircolors-nord/

# Verify fzf is installed
which fzf

# Check LS_COLORS is set
echo $LS_COLORS
```

### Completions not working

Rebuild the completion cache:

```bash
rm -rf ~/.cache/zsh/*
autoload -Uz compinit && compinit
```

### Syntax errors on load

Check for shell script errors:

```bash
# Run zsh in debug mode
zsh -xv

# Check specific file
zsh -n ~/.config/zsh/conf.d/40-plugins.zsh
```

## Resetting Configuration

### Soft Reset

Reload configuration without restarting:
```bash
source ~/.zshrc
```

### Hard Reset

Remove cache and restart:
```bash
rm -rf ~/.cache/zsh/*
rm -rf ~/.local/share/zinit
exec zsh
```

### Complete Reset

Remove all zsh data (keeps configuration):
```bash
rm -rf ~/.local/share/zsh/*
rm -rf ~/.local/state/zsh/*
rm -rf ~/.cache/zsh/*
exec zsh
```

## Getting Help

### Check Zinit Status

```bash
zinit status
zinit list
```

### View Loaded Files

```bash
# List all sourced files
echo $fpath

# Check if a specific file was loaded
whence -v function_name
```

### Debug Mode

Add to top of `~/.zshrc` for debugging:
```bash
set -x  # Enable trace
```

Remove or comment out when done debugging.

## Performance Tips

1. **Lazy load plugins**: Use zinit's turbo mode
2. **Reduce history size**: Lower HISTSIZE if needed
3. **Remove unused plugins**: Comment out plugins you don't use
4. **Use cache**: Most tools support caching, ensure it's enabled
5. **Defer expensive operations**: Move slow commands to background

## Reporting Issues

When reporting issues, include:
- ZSH version: `zsh --version`
- Operating system: `uname -a`
- Configuration location: `ls -la ~/.config/zsh/`
- Error messages
- Output of: `zsh -xv 2>&1 | head -50`
