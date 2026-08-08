{
  flake.modules.homeManager.praxis =
    {
      config,
      lib,
      ...
    }:
    {
      xdg.configFile."hypr/monitors.lua".source = ./assets/hyprland-monitors.lua;
    };
}
