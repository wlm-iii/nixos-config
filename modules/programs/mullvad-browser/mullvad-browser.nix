{
  flake.modules.homeManager.mullvad-browser =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        mullvad-browser
      ];
    };
}
