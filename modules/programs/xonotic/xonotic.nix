{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.xonotic = {
    home.packages = with pkgs; [
      xonotic
    ];
  };
}
