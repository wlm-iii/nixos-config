{
  flake.modules.homeManager.hyprland =
    {
      lib,
      pkgs,
      ...
    }:
    {
      xdg.autostart.enable = true;
      programs.hyprlock.enable = true;
      services.hyprpaper.enable = true;

      xdg.configFile = {
        "hypr/hyprland.lua".source = ./assets/hyprland.lua;
        "hypr/programs.lua".source = ./assets/programs.lua;
        "hypr/autostart.lua".source = ./assets/autostart.lua;
        "hypr/environment.lua".source = ./assets/environment.lua;
        "hypr/permissions.lua".source = ./assets/permissions.lua;
        "hypr/appearance.lua".source = ./assets/appearance.lua;
        "hypr/input.lua".source = ./assets/input.lua;
        "hypr/bindings.lua".source = ./assets/bindings.lua;
        "hypr/rules.lua".source = ./assets/rules.lua;

        # The generic fallback; a host may override this later.
        "hypr/monitors.lua".source = lib.mkDefault ./assets/monitors.lua;
      };

      home.packages = with pkgs; [
        hyprshutdown
        networkmanagerapplet
        playerctl
        brightnessctl
        swaynotificationcenter
        libnotify
        grim
        slurp
        wl-clipboard
        swappy
        lxqt.pavucontrol-qt
        gnome-firmware
        gparted
      ];
    };
}
