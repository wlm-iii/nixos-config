{
  ...
}:
{
  # default settings needed for all homeManager configurations
  flake.modules.homeManager.system-minimal =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      home.homeDirectory = "/home/${config.home.username}";
      home.stateVersion = "25.11";
    };
}
