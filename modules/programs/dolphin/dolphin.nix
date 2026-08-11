{
  flake.modules.homeManager.dolphin =
    {
      pkgs,
      ...
    }:
    {
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
