{
  flake.modules.homeManager.discordo =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        discordo
      ];
    };
}
