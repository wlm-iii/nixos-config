{
  flake.modules.homeManager.terminal-toys =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        tty-clock
        cmatrix
      ];
    };
}
