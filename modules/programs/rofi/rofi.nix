{
  flake.modules.homeManager.rofi =
    {
      pkgs,
      ...
    }:
    {
      programs.rofi = {
        enable = true;
        plugins = with pkgs; [
          rofi-calc
          rofi-emoji
        ];
        modes = [
          "drun"
          "window"
          "run"
          "calc"
          "ssh"
          "emoji"
        ];
      };
      home.packages = with pkgs; [
        libqalculate
      ];
    };
}
