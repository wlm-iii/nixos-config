{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.terminal-toys = {
    home.packages = with pkgs; [
      tty-clock
      cmatrix
    ];
  };
}
