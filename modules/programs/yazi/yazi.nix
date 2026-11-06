{
  flake.modules.homeManager.yazi =
    {
      pkgs,
      ...
    }:
    {
      programs.yazi = {
        enable = true;
        shellWrapperName = "y";

        plugins = with pkgs.yaziPlugins; {
          inherit mount;
        };

        extraPackages = with pkgs; [
          file
          udisks
          util-linux
          xdg-utils
        ];

        keymap.mgr.prepend_keymap = [
          {
            on = "M";
            run = "plugin mount";
            desc = "Manage disks and mounts";
          }
        ];

        settings = {
          opener = {
            zathura = [
              {
                run = "${pkgs.zathura}/bin/zathura %s1";
                orphan = true;
                desc = "Zathura";
                for = "linux";
              }
            ];

            xournalpp = [
              {
                run = "${pkgs.xournalpp}/bin/xournalpp %s1";
                orphan = true;
                desc = "Xournal++";
                for = "linux";
              }
            ];

            edit = [
              {
                run = "${pkgs.neovim}/bin/nvim %s";
                block = true;
                desc = "Neovim";
                for = "linux";
              }
            ];

            open = [
              {
                run = "${pkgs.xdg-utils}/bin/xdg-open %s1";
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
