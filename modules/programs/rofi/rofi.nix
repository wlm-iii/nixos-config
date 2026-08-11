{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.rofi = {
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
