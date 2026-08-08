{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.cmake = {
    home.packages = with pkgs; [
      cmake
      ninja
    ];
  };
}
