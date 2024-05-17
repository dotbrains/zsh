# Powerlevel10k prompt
# https://github.com/romkatv/powerlevel10k

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source "$HOME/.p10k.zsh"

# ---------------------------------------------------------

# Starship prompt
# https://starship.rs/
# The minimal, blazing-fast, and infinitely customizable prompt for any shell!

# By placing this at the top of your .zshrc, it will ensure that Starship is
# immediatly available for use - making the initialization of the shell faster.

if command -v starship &>/dev/null; then
	eval "$(starship init zsh)"
fi

# ---------------------------------------------------------

source "variables.zsh"
source "plugins.zsh"
source "snippets.zsh"

# ---------------------------------------------------------

source "keybindings.zsh"

# ---------------------------------------------------------

# History

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# ---------------------------------------------------------

source "completions.zsh"
source "aliases.zsh"
source "functions.zsh"

# ---------------------------------------------------------

# Shell integrations

# Check to see if the Mac needs Rosetta installed by testing the processor
processor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string | grep -o "Apple")

if [[ -n $processor ]]; then
	# 'brew' configurations
	eval "$(/opt/homebrew/bin/brew shellenv)"
else
	# 'brew' configurations
	eval "$(/usr/local/bin/brew shellenv)"
fi

eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
