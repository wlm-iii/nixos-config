{
  flake.modules.homeManager.mgba =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        mgba
      ];
    };
}
