{
  flake.modules.nixos.man =
    {
      pkgs,
      ...
    }:
    {
      documentation.man = {
        enable = true;
        cache.enable = true;
        man-db.enable = true;
      };
      environment.systemPackages = with pkgs; [
        man-pages
        man-pages-posix
      ];
    };
}
