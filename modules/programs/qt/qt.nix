{
  flake.modules.homeManager.qt = {
    qt = {
      enable = true;
      platformTheme.name = "qtct";

      qt5ctSettings = {
        Appearance = {
          icon_theme = "Gruvbox-Plus-Dark";
          standard_dialogs = "xdgdesktopportal";
        };
      };

      qt6ctSettings = {
        Appearance = {
          icon_theme = "Gruvbox-Plus-Dark";
          standard_dialogs = "xdgdesktopportal";
        };
      };
    };
  };
}
