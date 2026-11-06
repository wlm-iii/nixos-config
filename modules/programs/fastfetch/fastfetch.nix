{
  flake.modules.homeManager.fastfetch =
    {
      config,
      ...
    }:
    let
      colors = config.lib.stylix.colors.withHashtag;
    in
    {
      programs.fastfetch = {
        enable = true;
        settings = {
          "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
          "logo" = {
            type = "builtin";
            source = "nixos2";

            padding = {
              right = 2;
            };

            color = {
              "1" = colors.base0D;
              "2" = colors.base0B;
              "3" = colors.base0D;
              "4" = colors.base0B;
              "5" = colors.base0D;
              "6" = colors.base0B;
            };
          };
          display = {
            color.keys = colors.base09;

            separator = "    ";
            constants = [ "─────────────────" ];
            key = {
              type = "icon";
              paddingLeft = 2;
            };
          };
          modules = [
            {
              type = "custom";
              format = "┌{$1} {#1}Hardware Information{#} {$1}┐";
            }
            "host"
            "cpu"
            "gpu"
            "disk"
            "memory"
            "swap"
            {
              type = "custom";
              format = "├{$1} {#1}Software Information{#} {$1}┤";
            }
            {
              type = "title";
              keyIcon = "";
              key = "Title";
              format = "{user-name}";
            }
            {
              type = "title";
              keyIcon = "󰪫";
              key = "Title";
              format = "{host-name}";
            }
            "os"
            "kernel"
            "wm"
            "shell"
            "terminal"
            "terminalfont"
            # "packages"
            # "uptime"
            {
              type = "custom";
              format = "└{$1}──────────────────────{$1}┘";
            }
            {
              type = "colors";
              paddingLeft = 2;
              symbol = "circle";
            }
          ];
        };
      };
    };
}
