{
  flake.modules.homeManager.python =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        python314
      ];
    };
}
