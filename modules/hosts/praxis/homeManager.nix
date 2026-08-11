{
  inputs,
  ...
}:
{
  flake.modules.homeManager.praxis = {
    xdg.configFile."hypr/monitors.lua".source = ./assets/hyprland-monitors.lua;

    imports = with inputs.self.modules.homeManager; [
      system-desktop
    ];
  };
}
