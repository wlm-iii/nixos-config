{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.xournalpp = {
    home.packages = with pkgs; [
      xournalpp
    ];
  };
}
