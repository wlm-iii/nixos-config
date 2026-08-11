{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.dolphin = {
    home.packages = with pkgs.kdePackages; [
      dolphin
      dolphin-plugins
      ffmpegthumbs
      kdegraphics-thumbnailers
      qtsvg
      kio-admin
      kio-extras
      bluedevil
      kio-fuse
    ];
  };
}
