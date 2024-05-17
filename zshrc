# load local zsh configurations
[[ -s "$HOME/.zsh.local" ]] && source "$HOME"/.zsh.local

# zensh
# This configuration prioritizes zen and calm in order to reduce
# distractions and maintain momentum when working inside of the terminal.
source zensh/zen.zsh

# nord dircolors
# see: https://github.com/coltondick/zsh-dircolors-nord
source "zsh-dircolors-nord/zsh-dircolors-nord.zsh"

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
