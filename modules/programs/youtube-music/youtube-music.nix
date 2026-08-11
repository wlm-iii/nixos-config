{
  flake.modules.homeManager.youtube-music =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        pear-desktop
      ];
    };
}
