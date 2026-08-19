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

# Load terminal theme using theme.sh
# see: https://github.com/lemnos/theme.sh
SMU_PROFILE="${XDG_CONFIG_HOME:-$HOME/.config}/set-me-up/profile.env"
if [[ -f "$SMU_PROFILE" ]]; then
    smu_theme_before="${SMU_THEME:-}"
    smu_prompt_before="${SMU_PROMPT:-}"
    source "$SMU_PROFILE"
    [[ -n "$smu_theme_before" ]] && SMU_THEME="$smu_theme_before"
    [[ -n "$smu_prompt_before" ]] && SMU_PROMPT="$smu_prompt_before"
    unset smu_theme_before smu_prompt_before
fi

export SMU_THEME="${SMU_THEME:-gruvbox}"
export SMU_PROMPT="${SMU_PROMPT:-starship}"

if command -v theme &>/dev/null; then
    case "$SMU_THEME" in
        gruvbox)
            theme gruvbox-dark
            ;;
        nord)
            theme nord
            ;;
        catppuccin)
            theme catppuccin-macchiato
            ;;
        tokyo-night)
            theme tokyo-night
            ;;
        rose-pine)
            theme rose-pine
            ;;
        dracula)
            theme dracula
            ;;
        everforest)
            theme everforest
            ;;
        solarized)
            theme solarized-dark
            ;;
        kanagawa)
            theme kanagawa
            ;;
    esac
fi

# Load theme (set ZSH_THEME environment variable to change)
# Available themes match `smu theme list`.
# Default: gruvbox
ZSH_THEME="${ZSH_THEME:-$SMU_THEME}"

if [[ -d "$ZSH_CONFIG_DIR/themes/$ZSH_THEME" ]]; then
    source "$ZSH_CONFIG_DIR/themes/$ZSH_THEME/fzf.zsh"
    source "$ZSH_CONFIG_DIR/themes/$ZSH_THEME/bat.zsh"
    source "$ZSH_CONFIG_DIR/themes/$ZSH_THEME/dircolors.zsh"
else
    echo "Warning: Theme '$ZSH_THEME' not found. Available themes: gruvbox, nord"
fi

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
prompt_adapter="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}/prompts/${SMU_PROMPT}.zsh"
if [[ -r "$prompt_adapter" ]]; then
    source "$prompt_adapter"
elif command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
else
    PROMPT='%n@%m:%~%# '
fi
unset prompt_adapter

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# fzf integration
# Note: zoxide is initialized at the very end of zshrc so its hook is last.
# zoxide doctor warns when its init isn't the final line of the shell config.
if command -v fzf &>/dev/null; then
    eval "$(fzf --zsh)"
fi
