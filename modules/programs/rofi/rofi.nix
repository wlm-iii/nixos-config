{
  flake.modules.homeManager.rofi =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.lib.formats.rasi) mkLiteral;
      colors = config.lib.stylix.colors;
    in
    {
      stylix.targets.rofi.enable = false;

      programs.rofi = {
        enable = true;

        plugins = with pkgs; [
          rofi-calc
          rofi-emoji
        ];

        settings = {
          modes = [
            "drun"
            "window"
            "run"
            "calc"
            "ssh"
            "emoji"
          ];

          font = "${config.stylix.fonts.monospace.name} 12";

          show-icons = true;
          icon-theme = "Gruvbox-Plus-Dark";
          drun-display-format = "{name}";
        };

        theme = {
          "*" = {
            bg0 = mkLiteral "#${colors.base00}";
            bg1 = mkLiteral "#${colors.base01}";
            background = mkLiteral "#${colors.base00}CC";
            fg0 = mkLiteral "#${colors.base05}";
            orange = mkLiteral "#${colors.base09}";
            green = mkLiteral "#${colors.base0B}";

            background-color = mkLiteral "transparent";
            text-color = mkLiteral "@fg0";

          };

          element = {
            children = map mkLiteral [
              "element-icon"
              "element-text"
            ];
            spacing = mkLiteral "12px";
            padding = mkLiteral "6px";
          };

          element-icon = {
            size = mkLiteral "32px";
            vertical-align = mkLiteral "0.5";
          };

          element-text = {
            horizontal-align = mkLiteral "0.5";
            vertical-align = mkLiteral "0.5";
            text-color = mkLiteral "inherit";
          };

          window = {
            width = mkLiteral "640px";
            background-color = mkLiteral "@background";
          };

          prompt = {
            text-color = mkLiteral "@orange";
            spacing = mkLiteral "12px";
            padding = mkLiteral "12px";
            vertical-align = mkLiteral "0.5";
          };

          entry = {
            vertical-align = mkLiteral "0.5";
          };

          overlay.enabled = false;

          "element selected normal" = {
            background-color = mkLiteral "@green";
            text-color = mkLiteral "@bg0";
          };

          listview = {
            lines = 6;
            columns = 1;
            fixed-height = false;
          };
        };
      };

      home.packages = with pkgs; [
        libqalculate
        gruvbox-plus-icons
        networkmanager_dmenu
        rofi-bluetooth
      ];

      xdg.configFile."networkmanager-dmenu/config.ini".source =
        (pkgs.formats.ini { }).generate "networkmanager-dmenu.ini"
          {
            dmenu = {
              dmenu_command = "rofi -dmenu -i";
            };

            editor = {
              gui_if_available = true;
              gui = "nm-connection-editor";
            };
          };
    };
}
