{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.pdf-utils = {
    home.packages = with pkgs; [
      poppler-utils
    ];
  };
}
