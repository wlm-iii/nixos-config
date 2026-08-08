{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.yazi = {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";

      extraPackages = with pkgs; [
        file
        xdg-utils
      ];

      settings = {
        opener = {
          zathura = [
            {
              run = "${pkgs.zathura}/bin/zathura \"$1\"";
              orphan = true;
              desc = "Zathura";
              for = "linux";
            }
          ];

          xournalpp = [
            {
              run = "${pkgs.xournalpp}/bin/xournalpp \"$1\"";
              orphan = true;
              desc = "Xournal++";
              for = "linux";
            }
          ];

          edit = [
            {
              run = "${pkgs.neovim}/bin/nvim \"$@\"";
              block = true;
              desc = "Neovim";
              for = "linux";
            }
          ];

          open = [
            {
              run = "${pkgs.xdg-utils}/bin/xdg-open \"$1\"";
              orphan = true;
              desc = "Open";
              for = "linux";
            }
          ];
        };

        open.prepend_rules = [
          {
            mime = "application/pdf";
            use = [
              "zathura"
              "xournalpp"
              "open"
            ];
          }
          {
            url = "*.xopp";
            use = [
              "xournalpp"
              "open"
            ];
          }
        ];
      };
    };
  };
}
