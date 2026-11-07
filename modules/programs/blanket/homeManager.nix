{
  flake.modules.homeManager.blanket =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        blanket
      ];
    };
}
