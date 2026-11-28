{
  flake.modules.homeManager.hyprland =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      lockPanelColor = "rgba(${config.lib.stylix.colors.base00}e6)";
    in
    {
      xdg.autostart.enable = true;

      programs.hyprlock = {
        enable = true;

        settings = {
          general = {
            hide_cursor = true;
            ignore_empty_input = true;
          };

          background = {
            blur_passes = 2;
            blur_size = 6;
            brightness = 0.75;
          };

          input-field = {
            size = "280, 48";
            position = "0, -55";
            rounding = 0;
            outline_thickness = 2;
            inner_color = lib.mkForce lockPanelColor;
            outer_color = lib.mkForce "rgba(00000000)";
            fail_color = lib.mkForce "rgba(${config.lib.stylix.colors.base08}00)";
            fade_on_empty = false;
            font_family = config.stylix.fonts.monospace.name;
            placeholder_text = "<span font_family='JetBrainsMono Nerd Font Propo'></span>";
          };

          shape = {
            size = "280, 88";
            position = "0, 18";
            halign = "center";
            valign = "center";
            color = lockPanelColor;
            rounding = 0;
            border_size = 0;
            zindex = 0;
          };

          label = [
            {
              text = "$TIME12";
              font_family = config.stylix.fonts.monospace.name;
              font_size = 24;
              color = "rgb(${config.lib.stylix.colors.base05})";
              halign = "center";
              valign = "center";
              position = "0, 0";
              zindex = 1;
            }
            {
              text = "cmd[update:60000] ${pkgs.coreutils}/bin/date '+%a, %b %d'";
              font_family = config.stylix.fonts.monospace.name;
              font_size = 13;
              color = "rgb(${config.lib.stylix.colors.base05})";
              halign = "center";
              valign = "center";
              position = "0, 42";
              zindex = 1;
            }
          ];
        };
      };

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

        "hypr/hypr_switch_workspace.sh" = {
          source = ./assets/hypr_switch_workspace.sh;
          executable = true;
        };

        "hypr/hypr_move_to_workspace.sh" = {
          source = ./assets/hypr_move_to_workspace.sh;
          executable = true;
        };

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
