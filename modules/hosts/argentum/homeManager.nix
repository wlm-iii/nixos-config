{
  inputs,
  ...
}:
{
  flake.modules.homeManager.argentum = {
    xdg.configFile."hypr/monitors.lua".source = ./assets/hyprland-monitors.lua;

    programs.hyprlock.settings.auth.fingerprint.enabled = true;

    imports = with inputs.self.modules.homeManager; [
      system-desktop

      codex
      pi-agent
    ];
  };
}
