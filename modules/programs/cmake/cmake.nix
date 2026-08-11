{
  flake.modules.homeManager.cmake =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        cmake
        ninja
      ];
    };
}
