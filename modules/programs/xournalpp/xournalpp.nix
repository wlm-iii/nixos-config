{
  flake.modules.homeManager.xournalpp =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        xournalpp
      ];
    };
}
