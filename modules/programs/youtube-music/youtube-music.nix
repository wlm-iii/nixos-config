{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.youtube-music = {
    home.packages = with pkgs; [
      pear-desktop
    ];
  };
}
