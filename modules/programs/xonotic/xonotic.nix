{
  flake.modules.homeManager.xonotic =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        xonotic
      ];
    };
}
