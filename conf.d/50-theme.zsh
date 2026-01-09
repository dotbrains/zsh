#!/usr/bin/env zsh
# Theme and prompt configuration

# Powerlevel10k prompt (commented out by default)
# https://github.com/romkatv/powerlevel10k

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source "$HOME/.p10k.zsh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Load Nord theme
source "$ZSH_CONFIG_DIR/themes/nord/fzf.zsh"
source "$ZSH_CONFIG_DIR/themes/nord/bat.zsh"
source "$ZSH_CONFIG_DIR/themes/nord/dircolors.zsh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Homebrew
# see: https://brew.sh/

processor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string | grep -o "Apple")

if [[ -n $processor ]]; then
	# Set Homebrew paths manually to avoid shell detection issues
	export HOMEBREW_PREFIX="/opt/homebrew"
	export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
	export HOMEBREW_REPOSITORY="/opt/homebrew"
	export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
	export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
	export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
else
	# Configure linuxbrew
	# see: https://docs.brew.sh/Homebrew-on-Linux#install
	if test -d ~/.linuxbrew; then
		export PATH="$HOME/.linuxbrew/bin:$PATH"
	elif test -d /home/linuxbrew/.linuxbrew; then
		export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
	fi
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Starship prompt
# https://starship.rs/
# The minimal, blazing-fast, and infinitely customizable prompt for any shell!
if command -v starship &>/dev/null; then
	eval "$(starship init zsh)"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# fzf and zoxide integration
if command -v fzf &>/dev/null; then
    eval "$(fzf --zsh)"
fi

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init --cmd cd zsh)"
fi
