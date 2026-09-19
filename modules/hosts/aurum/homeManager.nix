{
  inputs,
  ...
}:
{
  flake.modules.homeManager.aurum = {
    xdg.configFile."hypr/monitors.lua".source = ./assets/hyprland-monitors.lua;

    imports = with inputs.self.modules.homeManager; [
      system-desktop

      codex
      pi-agent
    ];

    programs.btop = {
      settings = {
        shown_boxes = "cpu mem net proc gpu0";
        custom_gpu_name0 = "RTX 3070 Ti";
      };
    };
  };
}
