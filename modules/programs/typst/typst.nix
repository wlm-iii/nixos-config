{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.typst = {
    home.packages = with pkgs; [
      typst
    ];
  };
}
