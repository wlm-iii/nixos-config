{
  flake.modules.homeManager.fastfetch = {
    programs.fastfetch = {
      enable = true;
      settings = {
        "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
        "logo" = {
          type = "builtin";
          source = "nixos";

          padding = {
            right = 2;
          };
        };
        display = {
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
          "os"
          "kernel"
          "wm"
          "shell"
          "terminal"
          "terminalfont"
          "packages"
          "uptime"
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
