{ ... }:

{
  programs.zsh.enable = true;

  xdg.configFile."zsh".source = ./.;
}
