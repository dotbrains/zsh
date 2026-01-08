# zensh - A Zen ZSH Configuration

A minimal, modular, and XDG-compliant ZSH configuration prioritizing calm and focus to reduce distractions and maintain momentum when working in the terminal.

## Features

- ✨ **XDG Base Directory compliant** - Clean home directory, follows standards
- 📦 **Modular architecture** - Easy to extend and customize
- 🎨 **Nord theme** - Beautiful, consistent color scheme
- ⚡ **Fast startup** - Optimized loading with lazy evaluation
- 🔌 **Plugin management** - Uses zinit for efficient plugin handling
- 🎯 **Focused functionality** - Only what you need, nothing more

## Requirements

- ZSH 5.0 or later
- Git
- Optional but recommended:
  - [Starship](https://starship.rs/) - Fast, customizable prompt
  - [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
  - [zoxide](https://github.com/ajeetdsouza/zoxide) - Smarter cd command
  - [eza](https://github.com/eza-community/eza) - Modern ls replacement
  - [bat](https://github.com/sharkdp/bat) - Cat clone with syntax highlighting

## Usage

The contents of this repository should be placed in your `$HOME/.config`.

```bash
git clone --recursive https://github.com/dotbrains/zsh.git $HOME/.config/zsh
```

In your `$HOME` directory you would want a `.zshrc` that contains:

```bash
source "$HOME"/.config/zsh/zshrc
```

The configuration will automatically:
- Create necessary XDG directories on first run
- Initialize the zinit plugin manager
- Set up XDG-compliant paths for history, data, and cache

## Structure

```
.
├── zshrc                # Main configuration file
├── conf.d/              # Modular configuration (loaded in order)
├── aliases/             # Organized aliases
├── functions/           # Shell functions
│   └── git/             # Git-specific functions
├── themes/nord/         # Nord theme
├── zsh-dircolors-nord/  # Git submodule
├── docs/                # Documentation
└── README.md
```

## Documentation

- **[Configuration Guide](docs/configuration.md)** - Modular configuration, XDG compliance, customization
- **[Plugins](docs/plugins.md)** - Plugin management, adding plugins, troubleshooting
- **[Aliases](docs/aliases.md)** - Complete aliases reference
- **[Functions](docs/functions.md)** - Complete functions reference
- **[Troubleshooting](docs/troubleshooting.md)** - Common issues and solutions

## Quick Start

### Basic Configuration

The configuration automatically:
- Creates necessary XDG directories
- Installs zinit plugin manager
- Sets up history, completions, and key bindings
- Loads Nord theme
- Sources all aliases and functions

### Adding Customizations

Add machine-specific settings to `~/.config/zsh/local.zsh`:
```bash
# ~/.config/zsh/local.zsh
export MY_VARIABLE="value"
alias myalias="my command"
```

## Key Features

### Aliases
- Directory navigation: `..`, `...`, `....`
- Shell shortcuts: `:q`, `c`, `vim` → `nvim`
- Git: `acp`, `lg` (lazygit)
- Package managers: `brewi`, `npmi`, `ya`, `pipi`

### Functions
- General: `e`, `mkd`, `extract`, `u` (update all)
- Git: `gbl`, `gbs`, `ginfo`, `gstats`
- GitHub: `gh` (repository browser)
- Emoji-log: `gnew`, `gimp`, `gfix`, `grlz`

### Plugins (via zinit)
- `zsh-syntax-highlighting` - Syntax highlighting
- `zsh-completions` - Additional completions
- `zsh-autosuggestions` - Fish-like suggestions
- `fzf-tab` - FZF tab completion

## Themes

**Nord** - Default theme with:
- FZF colors
- Bat syntax highlighting
- Directory colors (via submodule)

## Uninstallation

1. Remove the configuration directory:
```bash
rm -rf ~/.config/zsh
```

2. Remove the source line from `~/.zshrc`

3. Optionally remove data directories:
```bash
rm -rf ~/.local/share/zsh
rm -rf ~/.local/state/zsh
rm -rf ~/.cache/zsh
```

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - See LICENSE file for details

## Credits

- Inspired by various ZSH configurations
- Nord theme by [Arctic Ice Studio](https://www.nordtheme.com/)
- Plugin manager: [zinit](https://github.com/zdharma-continuum/zinit)

## Related Projects

- [bash](https://github.com/dotbrains/bash) - Bash configuration
- [fish](https://github.com/dotbrains/fish) - Fish shell configuration
