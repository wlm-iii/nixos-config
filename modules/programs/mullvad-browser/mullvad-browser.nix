{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.mullvad-browser = {
    home.packages = with pkgs; [
      mullvad-browser
    ];
  };
}
