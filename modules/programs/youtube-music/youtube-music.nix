{
  flake.modules.homeManager.youtube-music =
    {
      config,
      pkgs,
      ...
    }:
    let
      colors = config.lib.stylix.colors.withHashtag;
    in
    {
      home.packages = [ pkgs.pear-desktop ];

      # Pear still uses the legacy "YouTube Music" config directory.
      # Once activated, select this symlink in:
      # Options > Visual Tweaks > Themes > Import CSS file.
      # Keep config.json writable: Pear stores other preferences there too.
      xdg.configFile."YouTube Music/themes/gruvbox.css".source = pkgs.replaceVars ./assets/gruvbox.css {
        inherit (colors)
          base00
          base01
          base02
          base03
          base04
          base05
          base08
          base09
          base0A
          base0B
          base0C
          ;
        monospaceFont = builtins.toJSON config.stylix.fonts.monospace.name;
      };
    };
}
