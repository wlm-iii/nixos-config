{
  flake.modules.homeManager.qt =
    {
      config,
      pkgs,
      ...
    }:
    let
      qtctSettings = {
        Appearance = {
          style = "kvantum";
          custom_palette = false;
          icon_theme = "Gruvbox-Plus-Dark";
          standard_dialogs = "xdgdesktopportal";
        };
        Fonts = {
          general = ''"${config.stylix.fonts.sansSerif.name},${toString config.stylix.fonts.sizes.applications}"'';
          fixed = ''"${config.stylix.fonts.monospace.name},${toString config.stylix.fonts.sizes.applications}"'';
        };
      };
    in
    {
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "kvantum";

        kvantum = {
          enable = true;
          themes = [ pkgs.gruvbox-kvantum ];
          settings.General.theme = "Gruvbox-Dark-Brown";
        };

        qt5ctSettings = qtctSettings;
        qt6ctSettings = qtctSettings;

        kde.settings = {
          dolphinrc.UiSettings.ColorScheme = "BreezeDark";
          kdeglobals = {
            Icons.Theme = "Gruvbox-Plus-Dark";
            KDE.widgetStyle = "kvantum";
          };
        };
      };
    };
}
