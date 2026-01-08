# Aliases Reference

See `~/.config/zsh/aliases/` for complete implementation.

## General

### Navigation
- `..` - Go up one directory
- `...` - Go up two directories
- `....` - Go up three directories
- `cd..` - Same as `..`

### Shell Shortcuts
- `:q`, `q` - Exit shell
- `c` - Clear screen
- `ch` - Clear history
- `m` - Man pages
- `path` - Print PATH with one entry per line
- `vim` - Opens nvim
- `x` - Make file executable (`chmod +x`)
- `z` - Zoxide command

### Listing Files
- `ls` - Enhanced with color (or eza if available)
- `l` - Long format listing (with eza)
- `ll` - Long format with icons (with eza)
- `lla` - Long format with hidden files
- `lsd` - List only directories
- `lsh` - List only hidden files

### Network
- `lip` - Get local IP address
- `xip` - Get external IP address

### System
- `afk` - Lock screen (macOS/Linux)
- `hide-desktop-icons` - Hide desktop icons
- `show-desktop-icons` - Show desktop icons
- `update` - Update all package managers (calls fish function if available)

## Git

- `acp` - Add all, commit, and push
- `lg` - Launch lazygit (if installed)
- `cz` - Commitizen for conventional commits (if npx available)

## Package Managers

### NPM
- `npmi` - Install package globally
- `npmr` - Uninstall package globally
- `npmls` - List global packages
- `npms` - Search for package
- `npmu` - Update npm

### Yarn
- `ya` - Add package
- `yr` - Remove package
- `yu` - Update yarn and packages

### Homebrew
- `brewi` - Install package
- `brewr` - Uninstall package
- `brews` - Search for package
- `brewd` - Run brew doctor
- `brewu` - Update brew and all packages

### Pip
- `pipi` - Install package
- `pipr` - Uninstall package
- `pipls` - List packages
- `pips` - Search for package
- `pipu` - Update pip and packages

### Pip3
- `pip3i` - Install package
- `pip3r` - Uninstall package
- `pip3ls` - List packages
- `pip3s` - Search for package
- `pip3u` - Update pip3 and packages

### Composer
- `ci` - Install dependencies
- `cr` - Remove package
- `cls` - List packages
- `cs` - Search for package
- `cu` - Update composer

## Tools

### Piknik (network clipboard)
- `pkc` - Copy to clipboard
- `pkp` - Paste from clipboard
- `pkm` - Move clipboard content
- `pkz` - Clear clipboard

### FZY (fuzzy finder)
- `fzyf` - Find files with fzy
- `fzyd` - Find directories with fzy

### Other
- `has` - Check for command line tools and versions
- `wttr` - Get weather from wttr.in
- `thefuck` - Command correction (if installed)
