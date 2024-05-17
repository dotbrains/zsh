# load local zsh configurations
source "$HOME"/.zsh.local

# zensh
# This configuration prioritizes zen and calm in order to reduce
# distractions and maintain momentum when working inside of the terminal.
source zensh/zen.zsh

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
